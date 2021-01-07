require "application_system_test_case"

class AppointmentsTest < ApplicationSystemTestCase
  setup do
    @held_item1 = create(:item)
    @held_item2 = create(:item)
    @borrowed_item1 = create(:item)
    @borrowed_item2 = create(:item)

    @member = create(:verified_member_with_membership)
    login_as @member.user
  end

  def check_row_with_name(item_name)
    within row_containing(item_name) do
      find("input[type=checkbox]").check
    end
  end

  def row_containing(text)
    find("tr", text: text)
  end

  test "schedules an appointment" do
    create(:event, calendar_id: Event.appointment_slot_calendar_id, start: 3.hours.since, finish: 4.hours.since)

    create(:started_hold, item: @held_item1, member: @member)
    create(:started_hold, item: @held_item2, member: @member)

    create(:loan, item: @borrowed_item1, member: @member)
    create(:loan, item: @borrowed_item2, member: @member)

    visit account_home_url

    click_on "Schedule a Pick Up"

    assert_text "Schedule an Appointment"

    check_row_with_name(@held_item1.complete_number)
    check_row_with_name(@borrowed_item1.complete_number)

    first_optgroup = find("#appointment_time_range_string optgroup", match: :first)
    selected_date = first_optgroup.value
    first_optgroup.find("option", match: :first).select_option

    fill_in "Optional: Tell us about the project you are working on. This may help us recommend a different or additional tool for you.", with: "Just a small project"
    click_on "Create Appointment"

    assert_text "Upcoming Appointments"
    assert_text selected_date
    assert_text @held_item1.complete_number
    assert_text @borrowed_item1.complete_number

    refute_text @held_item2.complete_number
    refute_text @borrowed_item2.complete_number

    visit account_home_url

    within row_containing(@held_item1.complete_number) { assert_text "Scheduled for pick-up" }
    within row_containing(@held_item2.complete_number) { assert_text "Ready for pickup" }
    within row_containing(@borrowed_item1.complete_number) { assert_text "Scheduled for drop-off" }
    within row_containing(@borrowed_item2.complete_number) { assert_text "Checked-out" }
  end
end
