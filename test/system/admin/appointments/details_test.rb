require "application_system_test_case"

module Admin
  class AppointmentDetailsTest < ApplicationSystemTestCase
    setup do
      starts_at = Time.current.beginning_of_day + 8.hours

      @member = create(:member)
      @hold = create(:hold, member: @member)
      @appointment = create(:appointment, member: @member, holds: [@hold], starts_at: starts_at + 2.hours, ends_at: starts_at + 4.hours)

      sign_in_as_admin
    end

    test "an admin can mark a pending appointment as pulled" do
      visit admin_appointment_path(@appointment)

      click_on "Pull Items"

      assert_text "Complete"
      assert_text "Mark As Not Pulled"

      @appointment.reload

      assert @appointment.pulled_at?
      refute @appointment.completed_at?
    end

    test "an admin can mark a pulled appointment as pending" do
      @appointment.update!(pulled_at: Time.current)

      visit admin_appointment_path(@appointment)

      click_on "Mark As Not Pulled"

      assert_text "Pull Items"

      @appointment.reload

      refute @appointment.pulled_at?
      refute @appointment.completed_at?
    end

    test "an admin can mark a pulled appointment as complete" do
      @appointment.update!(pulled_at: Time.current)

      visit admin_appointment_path(@appointment)

      click_on "Complete"

      assert_text "Restore"

      @appointment.reload

      assert @appointment.pulled_at?
      assert @appointment.completed_at?
    end

    test "an admin can mark a complete appointment as pulled" do
      @appointment.update!(pulled_at: Time.current, completed_at: Time.current)

      visit admin_appointment_path(@appointment)

      click_on "Restore"

      assert_text "Mark As Not Pulled"
      assert_text "Complete"

      @appointment.reload

      assert @appointment.pulled_at?
      refute @appointment.completed_at?
    end
  end
end
