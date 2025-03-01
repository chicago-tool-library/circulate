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

    assert_equal Time.zone.parse("2021-3-31 23:00"), appointment.starts_at
    assert_equal Time.zone.parse("2021-4-1 00:00"), appointment.ends_at
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

  test ".only_today filters the query to only include appointments that start today" do
    Time.use_zone("America/Chicago") do
      day_start = Time.zone.today.beginning_of_day
      day_end = Time.zone.today.end_of_day
      create(:appointment, starts_at: day_start - 1.second, ends_at: day_start, holds: [create(:hold)]) # yesterday
      appointments_for_today = [
        create(:appointment, starts_at: day_start + 1.second, ends_at: day_start + 10.seconds, holds: [create(:hold)]),
        create(:appointment, starts_at: day_end - 1.second, ends_at: day_end, holds: [create(:hold)])
      ]
      create(:appointment, starts_at: day_end + 1.second, ends_at: day_end + 3.seconds, holds: [create(:hold)]) # tomorrow

      assert_equal appointments_for_today.size, Appointment.all.only_today.count
      assert_equal appointments_for_today, Appointment.all.only_today
    end
  end

  test ".not_pulled filters the query to only include appointments that lack a pulled_at time" do
    create(:appointment, holds: [create(:hold)], pulled_at: 2.days.ago) # pulled
    not_pulled_appointments = [
      create(:appointment, holds: [create(:hold)], pulled_at: nil),
      create(:appointment, holds: [create(:hold)], pulled_at: nil)
    ]
    create(:appointment, holds: [create(:hold)], pulled_at: 3.days.ago) # pulled

    assert_equal not_pulled_appointments.size, Appointment.all.not_pulled.count
    assert_equal not_pulled_appointments, Appointment.all.not_pulled
  end

  test "#cancel_if_no_items!" do
    appointment = create(:appointment_with_holds)
    appointment.holds.destroy_all

    appointment.cancel_if_no_items!

    assert appointment.destroyed?
  end
end
