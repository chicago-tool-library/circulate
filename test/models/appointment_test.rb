require "test_helper"

class AppointmentTest < ActiveSupport::TestCase
  test "creates an appointment" do
    appointment = FactoryBot.build(:appointment)
    user = FactoryBot.create(:user)
    member = FactoryBot.create(:member, user: user)
    hold = FactoryBot.create(:hold, creator: member.user)
    appointment.holds << hold
    appointment.starts_at = "2020-10-05 7:00AM"
    appointment.ends_at = "2020-10-05 8:00AM"
    appointment.save
    assert_equal "Ida B. Wells", appointment.holds.first.member.full_name
    assert_equal "My Comment", appointment.comment
  end

  test "invalid without hold or loan selected and date not given" do
    appointment = Appointment.new
    appointment.save
    assert_equal appointment.errors[:base], ["Please select a date and time for this appointment.", "Please select an item to pick-up or return for your appointment"]
  end

  test "sets starts_at and ends_at using time_range_string=" do
    appointment = Appointment.new
    appointment.time_range_string = "2021-03-31 18:00:00 -0500..2021-03-31 19:00:00 -0500"

    assert_equal DateTime.new(2021, 3, 31, 23, 0, 0), appointment.starts_at
    assert_equal DateTime.new(2021, 4, 1, 0, 0, 0), appointment.ends_at
  end

  ["blarg..blarg", "boom", nil, ""].each do |value|
    test "handles invalid dates: #{value} (#{value.class})" do
      appointment = Appointment.new
      appointment.time_range_string = value

      refute appointment.starts_at
      refute appointment.ends_at
    end
  end

  test "finds a simultaneous appointments" do
    member = create(:member)
    hold = create(:hold, member: member)
    hold2 = create(:hold, member: member)
    original = create(:appointment, holds: [hold], member: member)
    dupe = create(:appointment, holds: [hold2], member: member, starts_at: original.starts_at, ends_at: original.ends_at)

    assert_equal [dupe], Appointment.simultaneous(original)
    assert_equal [original], Appointment.simultaneous(dupe)
  end

  test "merges appointments" do
    member = create(:member)
    hold = create(:hold, member: member)
    hold2 = create(:hold, member: member)
    loan = create(:loan, member: member)
    loan2 = create(:loan, member: member)
    original = create(:appointment,
      holds: [hold], loans: [loan], member: member, comment: "First notes")
    dupe = create(:appointment,
      holds: [hold2], loans: [loan2], member: member, comment: "Second notes",
      starts_at: original.starts_at, ends_at: original.ends_at)

    original.merge!(dupe)
    assert_raises(ActiveRecord::RecordNotFound) { dupe.reload }

    assert_equal [hold, hold2], original.holds
    assert_equal [loan, loan2], original.loans
    assert_equal "First notes\n\nSecond notes", original.comment
  end

  test "#cancel_if_no_items!" do
    appointment = create(:appointment_with_holds)
    appointment.holds.destroy_all

    appointment.cancel_if_no_items!

    assert appointment.destroyed?
  end
end
