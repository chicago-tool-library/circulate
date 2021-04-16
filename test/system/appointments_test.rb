require "application_system_test_case"

class AppointmentsTest < ApplicationSystemTestCase
  def check_row_with_name(item_name)
    within row_containing(item_name) do
      find("input[type=checkbox]").check
    end
  end

  def row_containing(text)
    find("tr", text: text)
  end

  def select_first_available_date
    first_optgroup = find("#appointment_time_range_string optgroup", match: :first)
    first_optgroup.find("option", match: :first).select_option
    first_optgroup.text
  end

  test "schedules an appointment" do
    @held_item1 = create(:item)
    @held_item2 = create(:item)
    @borrowed_item1 = create(:item)
    @borrowed_item2 = create(:item)

    @member = create(:verified_member_with_membership)

    login_as @member.user
    create(:event, calendar_id: Event.appointment_slot_calendar_id, start: 27.hours.since.beginning_of_hour, finish: 28.hours.since.beginning_of_hour)

    create(:started_hold, item: @held_item1, member: @member)
    create(:started_hold, item: @held_item2, member: @member)

    create(:loan, item: @borrowed_item1, member: @member)
    create(:loan, item: @borrowed_item2, member: @member)

    visit account_home_url

    click_on "Schedule a Pick Up"

    assert_text "Schedule an Appointment"

    check_row_with_name(@held_item1.complete_number)
    check_row_with_name(@borrowed_item1.complete_number)

    selected_date = select_first_available_date

    fill_in "Optional: Tell us about the project you are working on. This may help us recommend a different or additional tool for you.", with: "Just a small project"
    click_on "Create Appointment"

    assert_text "Appointments"
    assert_text selected_date
    assert_text @held_item1.complete_number
    assert_text @borrowed_item1.complete_number

    refute_text @held_item2.complete_number
    refute_text @borrowed_item2.complete_number

    visit account_home_url

    within(row_containing(@held_item1.complete_number)) { assert_text "Scheduled for pick-up" }
    within(row_containing(@held_item2.complete_number)) { assert_text "Ready for pickup" }
    within(row_containing(@borrowed_item1.complete_number)) { assert_text "Scheduled for return" }
    within(row_containing(@borrowed_item2.complete_number)) { assert_text "Checked-out" }
  end

  test "multiple members can make an appointment for an uncounted tool" do
    create(:event, calendar_id: Event.appointment_slot_calendar_id, start: 27.hours.since, finish: 28.hours.since)

    @held_item = create(:uncounted_item)
    @member = create(:verified_member_with_membership)
    @second_member = create(:verified_member_with_membership)

    create(:hold, item: @held_item, member: @member)
    create(:hold, item: @held_item, member: @second_member)

    [@member, @second_member].each do |member|
      login_as member.user

      visit account_home_url

      click_on "Schedule a Pick Up"

      assert_text "Schedule an Appointment"
      check_row_with_name(@held_item.complete_number)

      selected_date = select_first_available_date

      click_on "Create Appointment"

      assert_text "Appointments"
      assert_text selected_date
      assert_text @held_item.complete_number

      visit account_home_url

      within(row_containing(@held_item.complete_number)) { assert_text "Scheduled for pick-up" }
    end
  end

  test "updates an appointment" do
    @held_item1 = create(:item)
    @held_item2 = create(:item)

    @borrowed_item1 = create(:item)
    @borrowed_item2 = create(:item)

    @member = create(:verified_member_with_membership)

    login_as @member.user
    create(:event, calendar_id: Event.appointment_slot_calendar_id, start: 27.hours.since.beginning_of_hour, finish: 28.hours.since.beginning_of_hour)

    @hold1 = create(:hold, item: @held_item1, member: @member)
    @hold2 = create(:hold, item: @held_item2, member: @member)

    @loan1 = create(:loan, item: @borrowed_item1, member: @member)
    @loan2 = create(:loan, item: @borrowed_item2, member: @member)

    @appointment = create(:appointment, member: @member, starts_at: Time.now + 1.day, ends_at: Time.now + 1.day + 2.hours, holds: [@hold1], loans: [@loan1])

    visit account_home_url

    click_on "Appointments"

    assert_text "Appointments"

    click_on "Edit"

    check_row_with_name(@held_item2.complete_number)
    check_row_with_name(@borrowed_item2.complete_number)

    selected_date = select_first_available_date

    fill_in "Optional: Tell us about the project you are working on. This may help us recommend a different or additional tool for you.", with: "Updated appointment"
    click_on "Edit Appointment"

    assert_text "Appointments"
    assert_text selected_date
    assert_text "Updated appointment"
    assert_text @held_item1.complete_number
    assert_text @borrowed_item1.complete_number
    assert_text @held_item2.complete_number
    assert_text @borrowed_item2.complete_number

    visit account_home_url
    within(row_containing(@held_item1.complete_number)) { assert_text "Scheduled for pick-up" }
    within(row_containing(@held_item2.complete_number)) { assert_text "Scheduled for pick-up" }
    within(row_containing(@borrowed_item1.complete_number)) { assert_text "Scheduled for return" }
    within(row_containing(@borrowed_item2.complete_number)) { assert_text "Scheduled for return" }
  end
end
