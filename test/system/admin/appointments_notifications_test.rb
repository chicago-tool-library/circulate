require "application_system_test_case"

module Admin
  class AppointmentNotificationsTest < ApplicationSystemTestCase
    include AdminHelper

    setup do
      sign_in_as_admin
    end

    test "the not pulled notification message is not displayed when there aren't any unpulled appointments for today" do
      today = Time.zone.today.at_noon
      Timecop.travel(today)

      create(:appointment, holds: [create(:hold)], starts_at: 3.days.ago, ends_at: 3.days.ago + 10.minutes)
      create(:appointment, holds: [create(:hold)], starts_at: today.at_noon, ends_at: today.at_noon + 10.minutes, pulled_at: 3.hours.ago)

      # the specific path doesn't matter as long as it's in the admin interface
      visit admin_items_path

      refute_text "unpulled"
      Timecop.return
    end

    test "the not pulled notification message is displayed when there are unpulled appointments for today" do
      today = Time.zone.today.at_noon

      Timecop.travel(today)

      create(:appointment, holds: [create(:hold)], starts_at: 1.day.ago, ends_at: 1.day.ago + 10.minutes)
      create(:appointment, holds: [create(:hold)], starts_at: today.at_noon, ends_at: today.at_noon + 10.minutes, pulled_at: 3.hours.ago)
      create(:appointment, holds: [create(:hold)], starts_at: today.at_noon + 20.minutes, ends_at: today.at_noon + 30.minutes, pulled_at: nil)
      create(:appointment, holds: [create(:hold)], starts_at: today.at_noon + 40.minutes, ends_at: today.at_noon + 50.minutes, pulled_at: nil)

      # the specific path doesn't matter as long as it's in the admin interface
      visit admin_items_path

      assert_text "unpulled appointments"
      Timecop.return
    end

    test "a pulled appointment and its late-added items are highlighted in the schedule" do
      Timecop.travel(Time.zone.today.at_noon) do
        appointment = create(:appointment, holds: [create(:hold)], starts_at: Time.current, ends_at: 15.minutes.from_now)
        appointment.appointment_holds.update_all(created_at: 3.minutes.ago)
        appointment.update_column(:pulled_at, 2.minutes.ago)
        late_hold = create(:hold, item: create(:item, name: "Circular Saw"))
        create(:appointment_hold, appointment: appointment, hold: late_hold, created_at: Time.current)
        original_pulled_at = appointment.pulled_at

        visit admin_appointments_path(day: appointment.starts_at.to_date)

        within "tr.items-added-after-pull" do
          assert_text "Circular Saw"
          assert_selector ".label.label-error", text: "added after pull"
          click_button "mark new items pulled"
        end

        refute_selector "tr.items-added-after-pull"
        refute_selector ".label.label-error", text: "added after pull"
        assert_operator appointment.reload.pulled_at, :>, original_pulled_at
      end
    end

    test "completed appointments with late-added items are not highlighted" do
      Timecop.travel(Time.zone.today.at_noon) do
        appointment = create(:appointment, holds: [create(:hold)], starts_at: Time.current, ends_at: 15.minutes.from_now)
        appointment.update_columns(pulled_at: Time.current, completed_at: Time.current)
        create(:appointment_hold, appointment: appointment, created_at: 1.minute.from_now)

        visit admin_appointments_path(day: appointment.starts_at.to_date)

        refute_selector "tr.items-added-after-pull"
        refute_selector ".label.label-error", text: "added after pull"
      end
    end
  end
end
