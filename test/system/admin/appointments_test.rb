require "application_system_test_case"

module Admin
  class AppointmentsTest < ApplicationSystemTestCase
    include AdminHelper
    include ActionView::RecordIdentifier

    setup do
      sign_in_as_admin
    end

    test "marks an appointment as completed" do
      hold = create(:hold)
      appointment = create(:appointment, holds: [hold], member: hold.member)

      visit appointment_in_schedule_path(appointment)

      id = "#" + dom_id(appointment)
      within id do
        click_on "Complete"
      end

      assert_selector("#{id}.completed")

      assert appointment.reload.completed_at.present?

      within id do
        click_on "Restore"
      end

      refute_selector("#{id}.completed")

      assert appointment.reload.completed_at.nil?
    end
  end
end
