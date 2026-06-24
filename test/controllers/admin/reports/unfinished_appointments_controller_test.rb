require "test_helper"

module Admin
  module Reports
    class UnfinishedAppointmentsControllerTest < ActionDispatch::IntegrationTest
      include Devise::Test::IntegrationHelpers

      setup do
        @user = create(:admin_user)
        sign_in @user
      end

      test "lists pulled-but-never-completed appointments with items not checked out" do
        unfinished = create(:appointment, holds: [create(:hold)], pulled_at: 2.days.ago,
          starts_at: 2.days.ago, ends_at: 2.days.ago + 1.hour)
        completed = create(:appointment, holds: [create(:hold)], pulled_at: 2.days.ago,
          completed_at: 1.day.ago, starts_at: 2.days.ago, ends_at: 2.days.ago + 1.hour)

        get admin_reports_unfinished_appointments_url
        assert_response :success

        assert_select "a[href=?]", admin_appointment_path(unfinished)
        assert_select "a[href=?]", admin_appointment_path(completed), false,
          "completed appointments should not appear"
      end

      test "shows an empty state when nothing is unfinished" do
        get admin_reports_unfinished_appointments_url
        assert_response :success

        assert_select "table", false
      end

      test "marking an appointment complete resolves it and drops it from the list" do
        appointment = create(:appointment, holds: [create(:hold)], pulled_at: 2.days.ago,
          starts_at: 2.days.ago, ends_at: 2.days.ago + 1.hour)
        assert_includes Appointment.unfinished, appointment

        post complete_admin_reports_unfinished_appointment_url(appointment)

        assert_redirected_to admin_reports_unfinished_appointments_url
        assert appointment.reload.completed?
        refute_includes Appointment.unfinished, appointment
      end
    end
  end
end
