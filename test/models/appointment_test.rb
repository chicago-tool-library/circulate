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
    assert_equal appointment.errors[:base], ["Please select an item to pick-up or return for your appointment", "Please select a date and time for this appointment."]
  end
end
