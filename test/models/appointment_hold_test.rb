# frozen_string_literal: true

require "test_helper"

class AppointmentHoldTest < ActiveSupport::TestCase
  test "creates an appointment hold for member appointment" do
    appointment = FactoryBot.build(:appointment)
    user = FactoryBot.create(:user)
    member = FactoryBot.create(:member, user:)
    hold = FactoryBot.create(:hold, creator: member.user)
    hold_two = FactoryBot.create(:hold, creator: member.user)
    appointment.holds << hold
    appointment.holds << hold_two
    appointment.starts_at = "2020-10-05 7:00AM"
    appointment.ends_at = "2020-10-05 8:00AM"
    appointment.save
    assert_equal "Ida B. Wells", appointment.holds.first.member.full_name
    assert_equal 2, appointment.holds.length
  end
end
