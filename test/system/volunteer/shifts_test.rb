require "application_system_test_case"

module Volunteer
  class ShiftsTest < ApplicationSystemTestCase
    roles = ["Librarian (Senior)", "Librarian"]

    test "views shift calendar" do
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
      month = find(".calendar", text: date.strftime("%B"))
      within(month) do
        within(find(".calendar-date", text: date.mday), &block)
      end
    end

    # def check_list_item_with_name(item_name)
    #   within list_item_containing(item_name) do
    #     find("label").click # Styled checkboxes can't be toggled using #check
    #   end
    # end

    # def list_item_containing(text)
    #   find("li", text: text)
    # end

    # def select_first_available_date
    #   first_optgroup = find("#appointment_time_range_string optgroup", match: :first)
    #   first_optgroup.find("option", match: :first).select_option
    #   first_optgroup.text
    # end

    # test "schedules an appointment" do
    #   @held_item1 = create(:item)
    #   @held_item2 = create(:item)
    #   @borrowed_item1 = create(:item)
    #   @borrowed_item2 = create(:item)

    #   @member = create(:verified_member_with_membership)

    #   login_as @member.user
    #   create(:event, calendar_id: Event.appointment_slot_calendar_id, start: 27.hours.since.beginning_of_hour, finish: 28.hours.since.beginning_of_hour)

    #   create(:started_hold, item: @held_item1, member: @member)
    #   create(:started_hold, item: @held_item2, member: @member)

    #   create(:loan, item: @borrowed_item1, member: @member)
    #   create(:loan, item: @borrowed_item2, member: @member)

    #   visit account_holds_url

    #   click_on "Schedule a Pick Up"

    #   assert_text "Schedule an Appointment"

    #   check_list_item_with_name(@held_item1.complete_number)
    #   check_list_item_with_name(@borrowed_item1.complete_number)

    #   selected_date = select_first_available_date

    #   fill_in "Optional: Tell us about the project you are working on. This may help us recommend a different or additional tool for you.", with: "Just a small project"
    #   click_on "Schedule Appointment"

    #   assert_text "Appointments"
    #   assert_text selected_date
    #   assert_text @held_item1.complete_number
    #   assert_text @borrowed_item1.complete_number

    #   refute_text @held_item2.complete_number
    #   refute_text @borrowed_item2.complete_number

    #   visit account_home_url

    #   within(list_item_containing(@borrowed_item1.complete_number)) { assert_text "Scheduled for return" }
    #   within(list_item_containing(@borrowed_item2.complete_number)) { assert_text "Due" }

    #   visit account_holds_url

    #   within(list_item_containing(@held_item1.complete_number)) { assert_text "Scheduled for pick-up" }
    #   within(list_item_containing(@held_item2.complete_number)) { assert_text "Ready for pickup" }
    # end

    # test "multiple members can make an appointment for an uncounted tool" do
    #   create(:event, calendar_id: Event.appointment_slot_calendar_id, start: 27.hours.since, finish: 28.hours.since)

    #   @held_item = create(:uncounted_item)
    #   @member = create(:verified_member_with_membership)
    #   @second_member = create(:verified_member_with_membership)

    #   create(:hold, item: @held_item, member: @member)
    #   create(:hold, item: @held_item, member: @second_member)

    #   [@member, @second_member].each do |member|
    #     login_as member.user

    #     visit account_holds_path

    #     click_on "Schedule a Pick Up"

    #     assert_text "Schedule an Appointment"
    #     check_list_item_with_name(@held_item.complete_number)

    #     selected_date = select_first_available_date

    #     click_on "Schedule Appointment"

    #     assert_selector "h1", text: "Appointments", wait: 10
    #     assert_equal account_appointments_path, current_path
    #     assert_text selected_date
    #     assert_text @held_item.complete_number

    #     visit account_holds_url
    #     within(list_item_containing(@held_item.complete_number)) { assert_text "Scheduled for pick-up" }
    #   end
    # end

    # test "updates an appointment" do
    #   @held_item1 = create(:item)
    #   @held_item2 = create(:item)

    #   @borrowed_item1 = create(:item)
    #   @borrowed_item2 = create(:item)

    #   @member = create(:verified_member_with_membership)

    #   login_as @member.user
    #   create(:event, calendar_id: Event.appointment_slot_calendar_id, start: 27.hours.since.beginning_of_hour, finish: 28.hours.since.beginning_of_hour)

    #   @hold1 = create(:hold, item: @held_item1, member: @member)
    #   @hold2 = create(:hold, item: @held_item2, member: @member)

    #   @loan1 = create(:loan, item: @borrowed_item1, member: @member)
    #   @loan2 = create(:loan, item: @borrowed_item2, member: @member)

    #   @appointment = create(:appointment, member: @member, starts_at: Time.now + 1.day, ends_at: Time.now + 1.day + 2.hours, holds: [@hold1], loans: [@loan1])

    #   visit account_home_url

    #   click_on "Appointments"

    #   assert_text "Appointments"

    #   click_on "Modify Appointment"

    #   check_list_item_with_name(@held_item2.complete_number)
    #   check_list_item_with_name(@borrowed_item2.complete_number)

    #   selected_date = select_first_available_date

    #   fill_in "Optional: Tell us about the project you are working on. This may help us recommend a different or additional tool for you.", with: "Updated appointment"
    #   click_on "Update Appointment"

    #   assert_text "Appointments"
    #   assert_text selected_date

    #   assert_text "Updated appointment"

    #   assert_text @held_item1.complete_number
    #   assert_text @borrowed_item1.complete_number
    #   assert_text @held_item2.complete_number
    #   assert_text @borrowed_item2.complete_number

    #   visit account_home_url
    #   within(list_item_containing(@borrowed_item1.complete_number)) { assert_text "Scheduled for return" }
    #   within(list_item_containing(@borrowed_item2.complete_number)) { assert_text "Scheduled for return" }

    #   visit account_holds_url
    #   within(list_item_containing(@held_item1.complete_number)) { assert_text "Scheduled for pick-up" }
    #   within(list_item_containing(@held_item2.complete_number)) { assert_text "Scheduled for pick-up" }
    # end

    # test "schedules two appointments for the same time" do
    #   @held_item1 = create(:item)
    #   @held_item2 = create(:item)

    #   @borrowed_item1 = create(:item)
    #   @borrowed_item2 = create(:item)

    #   @member = create(:verified_member_with_membership)

    #   login_as @member.user
    #   create(:event, calendar_id: Event.appointment_slot_calendar_id, start: 27.hours.since.beginning_of_hour, finish: 28.hours.since.beginning_of_hour)

    #   @hold1 = create(:hold, item: @held_item1, member: @member)
    #   @hold2 = create(:hold, item: @held_item2, member: @member)

    #   @loan1 = create(:loan, item: @borrowed_item1, member: @member)
    #   @loan2 = create(:loan, item: @borrowed_item2, member: @member)

    #   visit new_account_appointment_path(@appointment)

    #   check_list_item_with_name(@held_item1.complete_number)
    #   check_list_item_with_name(@borrowed_item1.complete_number)
    #   select_first_available_date
    #   fill_in "Optional: Tell us about the project you are working on. This may help us recommend a different or additional tool for you.", with: "First appointment"
    #   click_on "Schedule Appointment"

    #   visit new_account_appointment_path(@appointment)
    #   check_list_item_with_name(@held_item2.complete_number)
    #   check_list_item_with_name(@borrowed_item2.complete_number)
    #   select_first_available_date

    #   fill_in "Optional: Tell us about the project you are working on. This may help us recommend a different or additional tool for you.", with: "Second appointment"
    #   click_on "Schedule Appointment"

    #   assert_text "existing appointment"
    #   assert_selector "li.appointment", count: 1

    #   assert_text @held_item1.complete_number
    #   assert_text @held_item2.complete_number
    #   assert_text @borrowed_item1.complete_number
    #   assert_text @borrowed_item2.complete_number
    #   assert_text "First appointment"
    #   assert_text "Second appointment"
    # end
  end
end
