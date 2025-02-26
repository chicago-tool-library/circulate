require "application_system_test_case"

module Admin
  class AppointmentsTest < ApplicationSystemTestCase
    include AdminHelper
    include ActionView::RecordIdentifier

    setup do
      starts_at = Time.current.beginning_of_day + 8.hours

      @member1 = create(:member, preferred_name: "Member 1")
      @member2 = create(:member, preferred_name: "Member 2")
      @member3 = create(:member, preferred_name: "Member 3")
      @member4 = create(:member, preferred_name: "Member 4")

      @hold1 = create(:hold, member: @member1)
      @hold2 = create(:hold, member: @member2)
      @hold3 = create(:hold, member: @member3)
      @hold4 = create(:hold, member: @member4)

      @appointment1 = create(:appointment, member: @member1, holds: [@hold1], starts_at: starts_at + 2.hours, ends_at: starts_at + 4.hours)
      @appointment2 = create(:appointment, member: @member2, holds: [@hold2], starts_at: starts_at, ends_at: starts_at + 2.hours)
      @appointment3 = create(:appointment, member: @member3, holds: [@hold3], starts_at: starts_at + 4.hours, ends_at: starts_at + 6.hours)
      @appointment4 = create(:appointment, member: @member4, holds: [@hold4], starts_at: starts_at, ends_at: starts_at + 2.hours)

      sign_in_as_admin
    end

    def assert_appointments_in_page(pending: [], pulled: [], completed: [])
      pending_appointment_ids = all(".pending-appointments .appointment").map { |row| row["data-appointment-id"].to_i }
      assert_equal pending.map(&:id), pending_appointment_ids

      pulled_appointment_ids = all(".pulled-appointments .appointment").map { |row| row["data-appointment-id"].to_i }
      assert_equal pulled.map(&:id), pulled_appointment_ids

      completed_appointment_ids = all(".completed-appointments .appointment").map { |row| row["data-appointment-id"].to_i }
      assert_equal completed.map(&:id), completed_appointment_ids
    end

    def id_selector(appointment)
      "##{dom_id(appointment)}"
    end

    def pull_items_for_appointment(appointment)
      within id_selector(appointment) do
        click_on "Pull Items"
      end
    end

    def complete_appointment(appointment)
      within id_selector(appointment) do
        click_on "Complete"
      end
    end

    def restore_appointment(appointment)
      within id_selector(appointment) do
        click_on "Restore"
      end
    end

    def mark_appointment_as_not_pulled(appointment)
      within id_selector(appointment) do
        click_on "Mark As Not Pulled"
      end
    end

    def assert_appointment_pulled(appointment)
      assert_selector("#{id_selector(appointment)}.pulled")
      assert_selector(".pulled-appointments #{id_selector(appointment)}")
    end

    def assert_appointment_completed(appointment)
      assert_selector("#{id_selector(appointment)}.completed")
      assert_selector(".completed-appointments #{id_selector(appointment)}")
    end

    def assert_appointment_pending(appointment)
      refute_selector("#{id_selector(appointment)}.completed")
      assert_selector(".pending-appointments #{id_selector(appointment)}")
    end

    test "moves appointments between lists" do
      visit appointment_in_schedule_path(@appointment2)

      assert_appointments_in_page pending: [
        @appointment2,
        @appointment4,
        @appointment1,
        @appointment3
      ]

      pull_items_for_appointment(@appointment2)
      assert_appointment_pulled(@appointment2)

      assert_appointments_in_page pending: [
        @appointment4,
        @appointment1,
        @appointment3
      ], pulled: [
        @appointment2
      ]

      complete_appointment(@appointment2)
      assert_appointment_completed(@appointment2)

      assert_appointments_in_page pending: [
        @appointment4,
        @appointment1,
        @appointment3
      ], completed: [
        @appointment2
      ]

      restore_appointment(@appointment2)
      assert_appointment_pulled(@appointment2)

      assert_appointments_in_page pending: [
        @appointment4,
        @appointment1,
        @appointment3
      ], pulled: [
        @appointment2
      ]

      mark_appointment_as_not_pulled(@appointment2)
      assert_appointment_pending(@appointment2)

      assert_appointments_in_page pending: [
        @appointment2,
        @appointment4,
        @appointment1,
        @appointment3
      ]
    end

    test "keeps appointments in order when changing lists" do
      visit appointment_in_schedule_path(@appointment1)

      pull_items_for_appointment(@appointment3)
      assert_appointment_pulled(@appointment3)

      pull_items_for_appointment(@appointment2)
      assert_appointment_pulled(@appointment2)

      pull_items_for_appointment(@appointment1)
      assert_appointment_pulled(@appointment1)

      assert_appointments_in_page pending: [
        @appointment4
      ], pulled: [
        @appointment2,
        @appointment1,
        @appointment3
      ]

      mark_appointment_as_not_pulled(@appointment2)
      assert_appointment_pending(@appointment2)

      assert_appointments_in_page pending: [
        @appointment2,
        @appointment4
      ], pulled: [
        @appointment1,
        @appointment3
      ]
    end

    test "marks an appointment as pulled" do
      visit appointment_in_schedule_path(@appointment2)

      pull_items_for_appointment(@appointment2)
      assert_appointment_pulled(@appointment2)

      assert @appointment2.reload.pulled_at.present?

      mark_appointment_as_not_pulled(@appointment2)

      assert_appointment_pending(@appointment2)
      assert @appointment2.reload.pulled_at.nil?
    end

    test "marks an appointment as completed" do
      @appointment2.update!(pulled_at: Time.current)
      visit appointment_in_schedule_path(@appointment2)

      complete_appointment(@appointment2)
      assert_appointment_completed(@appointment2)

      assert @appointment2.reload.completed_at.present?

      restore_appointment(@appointment2)

      assert_appointment_pulled(@appointment2)
      assert @appointment2.reload.completed_at.nil?
    end
  end
end
