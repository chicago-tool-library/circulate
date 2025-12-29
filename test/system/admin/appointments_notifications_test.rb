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
  end
end
