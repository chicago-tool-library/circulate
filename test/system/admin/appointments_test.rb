require "application_system_test_case"

module Admin
  class AppointmentsTest < ApplicationSystemTestCase
    include AdminHelper
    include ActionView::RecordIdentifier

    setup do
      starts_at = Time.current.beginning_of_day + 8.hours

      @member_1 = create(:member, preferred_name: "Member 1")
      @member_2 = create(:member, preferred_name: "Member 2")
      @member_3 = create(:member, preferred_name: "Member 3")
      @member_4 = create(:member, preferred_name: "Member 4")

      @hold_1_1 = create(:hold, member: @member_1)
      @hold_2_1 = create(:hold, member: @member_2)
      @hold_2_2 = create(:hold, member: @member_2)
      @hold_2_3 = create(:hold, member: @member_2)
      @hold_3_1 = create(:hold, member: @member_3)
      @hold_4_1 = create(:hold, member: @member_4)

      @appointment_1_1 = create(:appointment, member: @member_1, holds: [@hold_1_1], starts_at: starts_at, ends_at: starts_at + 2.hours)
      @appointment_2_1 = create(:appointment, member: @member_2, holds: [@hold_2_1], starts_at: starts_at, ends_at: starts_at + 2.hours)
      @appointment_2_2 = create(:appointment, member: @member_2, holds: [@hold_2_2], starts_at: starts_at + 2.hours, ends_at: starts_at + 4.hours)
      @appointment_2_3 = create(:appointment, member: @member_2, holds: [@hold_2_3], starts_at: starts_at + 6.hours, ends_at: starts_at + 8.hours)
      @appointment_3_1 = create(:appointment, member: @member_3, holds: [@hold_3_1], starts_at: starts_at + 4.hours, ends_at: starts_at + 6.hours)
      @appointment_4_1 = create(:appointment, member: @member_4, holds: [@hold_4_1], starts_at: starts_at, ends_at: starts_at + 2.hours)

      @appointments = [
        @appointment_1_1,
        @appointment_2_1,
        @appointment_2_2,
        @appointment_2_3,
        @appointment_3_1,
        @appointment_4_1
      ]

      sign_in_as_admin
    end

    def assert_appointments_in_page(pending: [], completed: [])
      pending_appointment_ids = all("table.pending-appointments tbody tr").map { |row| row["data-appointment-id"].to_i }
      assert_equal pending.map(&:id), pending_appointment_ids

      completed_appointment_ids = all("table.completed-appointments tbody tr").map { |row| row["data-appointment-id"].to_i }
      assert_equal completed.map(&:id), completed_appointment_ids
    end

    def complete_appointment(appointment)
      id = "#" + dom_id(appointment)
      within id do
        click_on "Complete"
      end
    end

    def restore_appointment(appointment)
      id = "#" + dom_id(appointment)
      within id do
        click_on "Restore"
      end
    end

    def assert_appointment_completed(appointment)
      id = dom_id(appointment)
      assert_selector("##{id}.completed")
      assert_selector("table.completed-appointments ##{id}")
    end

    def assert_appointment_pending(appointment)
      id = dom_id(appointment)
      refute_selector("##{id}.completed")
      assert_selector("table.pending-appointments ##{id}")
    end

    test "groups appointments for the same member together" do
      visit appointment_in_schedule_path(@appointment_1_1)

      assert_appointments_in_page pending: [
        @appointment_1_1,
        @appointment_2_1,
        @appointment_2_2,
        @appointment_2_3,
        @appointment_4_1,
        @appointment_3_1
      ]
    end

    test "moves appointments between lists" do
      visit appointment_in_schedule_path(@appointment_2_2)

      complete_appointment(@appointment_2_2)
      assert_appointment_completed(@appointment_2_2)

      assert_appointments_in_page pending: [
        @appointment_1_1,
        @appointment_2_1,
        @appointment_2_3,
        @appointment_4_1,
        @appointment_3_1
      ], completed: [
        @appointment_2_2
      ]

      visit appointment_in_schedule_path(@appointment_1_1)

      assert_appointments_in_page pending: [
        @appointment_1_1,
        @appointment_2_1,
        @appointment_2_3,
        @appointment_4_1,
        @appointment_3_1
      ], completed: [
        @appointment_2_2
      ]
    end

    test "restores appointments to the top of a member group" do
      @appointment_2_1.update(completed_at: Time.current)

      visit appointment_in_schedule_path(@appointment_2_1)

      assert_appointments_in_page pending: [
        @appointment_1_1,
        @appointment_2_2,
        @appointment_2_3,
        @appointment_4_1,
        @appointment_3_1
      ], completed: [
        @appointment_2_1
      ]

      restore_appointment(@appointment_2_1)
      assert_appointment_pending(@appointment_2_1)

      visit appointment_in_schedule_path(@appointment_2_1)

      assert_appointments_in_page pending: [
        @appointment_1_1,
        @appointment_2_1,
        @appointment_2_2,
        @appointment_2_3,
        @appointment_4_1,
        @appointment_3_1
      ]
    end

    test "marks an appointment as completed" do
      visit appointment_in_schedule_path(@appointment_2_2)

      complete_appointment(@appointment_2_2)
      assert_appointment_completed(@appointment_2_2)

      assert @appointment_2_2.reload.completed_at.present?

      restore_appointment(@appointment_2_2)

      assert_appointment_pending(@appointment_2_2)
      assert @appointment_2_2.reload.completed_at.nil?
    end
  end
end
