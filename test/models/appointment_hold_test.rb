require "test_helper"

class AppointmentHoldTest < ActiveSupport::TestCase
  test "creates an appointment hold for member appointment" do
    appointment = FactoryBot.create(:appointment)
    user = FactoryBot.create(:user)
    member = FactoryBot.create(:member, user: user)
    hold = FactoryBot.create(:hold, creator: member.user)
    hold_two = FactoryBot.create(:hold, creator: member.user)
    appointment_hold = FactoryBot.create(:appointment_hold, appointment: appointment, hold: hold)
    appointment_hold_two = FactoryBot.create(:appointment_hold, appointment: appointment, hold: hold_two)
    assert_equal "Ida B. Wells", appointment_hold.hold.member.full_name
    assert_equal 2, appointment.holds.length
  end
end
