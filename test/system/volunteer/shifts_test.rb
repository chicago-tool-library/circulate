# frozen_string_literal: true

require "application_system_test_case"

module Volunteer
  class ShiftsTest < ApplicationSystemTestCase
    roles = ["Librarian (Senior)", "Librarian"]

    test "views shift calendar" do
      skip "Redirecting to teamup for volunteer signups instead"
      visit test_google_auth_url(email: "volunteer@example.com")

      Time.use_zone("America/Chicago") do
        morning = Time.zone.now.beginning_of_day

        events = roles.flat_map do |role|
          (1..7).each.map do |offset|
            create(:event,
              summary: role,
              calendar_id: Event.volunteer_shift_calendar_id,
              start: morning.advance(hours: 9, days: offset),
              finish: morning.advance(hours: 13, days: offset))
          end
        end

        visit volunteer_shifts_url

        assert_text "Volunteer Shifts"

        first_event = events.first

        within_day(first_event.start) do
          find("a", text: /9am - 1pm/).click
        end

        assert_text "There are 2 roles available"
        assert_text first_event.summary

        click_on "Sign up as a Librarian (Senior)"

        assert_text "You have signed up for the shift."

        within_day(first_event.start) do
          find("a", text: /9am - 1pm/).click
        end

        assert_text "You are signed up!"
      end
    end

    def within_day(date, &block)
      within(find(".calendar-date[data-test-date='#{date.to_date}']"), &block)
    end
  end
end
