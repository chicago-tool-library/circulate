# frozen_string_literal: true

require "test_helper"

module Admin
  module Members
    class AppointmentsControllerTest < ActionDispatch::IntegrationTest
      include Devise::Test::IntegrationHelpers

      setup do
        @admin_user = create(:admin_user, member: @member_2)
        sign_in @admin_user
      end

      test "should create an appointment for a member" do
        member = create(:member)
        starts_at = Time.current
        ends_at = starts_at + 2.hours

        assert_difference("member.appointments.count", 1) do
          post admin_member_appointments_path(member), params: { appointment: { time_range_string: "#{starts_at}..#{ends_at}" } }
        end
        assert_redirected_to admin_appointment_path(member.reload.appointments.last)
      end
    end
  end
end
