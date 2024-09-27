require "application_system_test_case"

class AppointmentsTest < ApplicationSystemTestCase
  def check_list_item_with_name(item_name)
    within list_item_containing(item_name) do
      find("label").click # Styled checkboxes can't be toggled using #check
    end
  end

  def list_item_containing(text)
    find("li", text: text)
  end

  def select_first_available_date
    first_optgroup = find("#appointment_time_range_string optgroup", match: :first)
    first_optgroup.find("option", match: :first).select_option
    first_optgroup.text
  end

  def fill_in_optional_field(text)
    fill_in "Tell us about the project you're working on. We may be able to recommend a different or additional tool. If you're dropping off, please let us know if you had any issues with the items you're returning.", with: text
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

    visit account_holds_url

    click_on "Schedule a Pick Up"

    assert_text "Schedule an Appointment"

    check_list_item_with_name(@held_item1.complete_number)
    check_list_item_with_name(@borrowed_item1.complete_number)

    selected_date = select_first_available_date

    fill_in_optional_field("Just a small project")
    click_on "Schedule Appointment"

    assert_text "Appointments"
    assert_text selected_date
    assert_text "Just a small project"
    assert_text @held_item1.complete_number
    assert_text @borrowed_item1.complete_number

    refute_text @held_item2.complete_number
    refute_text @borrowed_item2.complete_number

    visit account_home_url

    assert_text "You have 2 items checked out"
    assert_text "You have 2 items ready to be picked up"

    visit account_loans_url

    within(list_item_containing(@borrowed_item1.complete_number)) { assert_text "Scheduled for return" }
    within(list_item_containing(@borrowed_item2.complete_number)) { assert_text "Due" }

    visit account_holds_url

    within(list_item_containing(@held_item1.complete_number)) { assert_text "Scheduled for pick-up" }
    within(list_item_containing(@held_item2.complete_number)) { assert_text "Ready for pickup" }
  end

  test "attempts to schedule an appointment with no holds" do
    @member = create(:verified_member_with_membership)

    login_as @member.user

    visit account_appointments_url

    click_on "Schedule an Appointment"

    assert_text "You can only schedule an appointment if"

    refute_text "Select Items to Return"
  end

  test "attempts to schedule appiontment for a hold in maintenance" do
    @member = create(:verified_member_with_membership)

    login_as @member.user
    create(:event, calendar_id: Event.appointment_slot_calendar_id, start: 27.hours.since.beginning_of_hour, finish: 28.hours.since.beginning_of_hour)

    @active_item = create(:item)
    @maintenance_item = create(:item)

    create(:started_hold, item: @active_item, member: @member)
    create(:hold, item: @maintenance_item, member: @member)

    @maintenance_item.update(status: Item.statuses[:maintenance])

    visit account_holds_url

    within list_item_containing(@active_item.complete_number) do
      assert_text "Ready for pickup"
    end

    within list_item_containing(@maintenance_item.complete_number) do
      assert_text "#1 on wait list"
    end

    click_on "Schedule a Pick Up"

    assert_text "Schedule an Appointment"

    within list_item_containing(@active_item.complete_number) do
      assert_text "Ready for pickup"
    end

    refute_text @maintenance_item.complete_number
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

      visit account_holds_path

      click_on "Schedule a Pick Up"

      assert_text "Schedule an Appointment"
      check_list_item_with_name(@held_item.complete_number)

      selected_date = select_first_available_date

      click_on "Schedule Appointment"

      assert_selector "h1", text: "Appointments", wait: slow_op_wait_time
      assert_equal account_appointments_path, current_path
      assert_text selected_date
      assert_text @held_item.complete_number

      visit account_holds_url
      within(list_item_containing(@held_item.complete_number)) { assert_text "Scheduled for pick-up" }
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

    @appointment = create(:appointment, member: @member, starts_at: 1.day.from_now, ends_at: 1.day.from_now + 2.hours, holds: [@hold1], loans: [@loan1])

    visit account_home_url

    within(".navigation-links") do
      find("#nav-borrow-tools-label").hover
      click_on "Appointments"
    end

    assert_text "Appointments"

    click_on "Modify Appointment"

    check_list_item_with_name(@held_item2.complete_number)
    check_list_item_with_name(@borrowed_item2.complete_number)

    selected_date = select_first_available_date

    fill_in_optional_field("Updated appointment")
    click_on "Update Appointment"

    assert_text "Appointments"
    assert_text selected_date

    assert_text "Updated appointment"

    assert_text @held_item1.complete_number
    assert_text @borrowed_item1.complete_number
    assert_text @held_item2.complete_number
    assert_text @borrowed_item2.complete_number

    visit account_home_url
    assert_text "You have 2 items checked out"
    assert_text "You have 2 items on hold but not ready for pickup"

    visit account_loans_url
    within(list_item_containing(@borrowed_item1.complete_number)) { assert_text "Scheduled for return" }
    within(list_item_containing(@borrowed_item2.complete_number)) { assert_text "Scheduled for return" }

    visit account_holds_url
    within(list_item_containing(@held_item1.complete_number)) { assert_text "Scheduled for pick-up" }
    within(list_item_containing(@held_item2.complete_number)) { assert_text "Scheduled for pick-up" }
  end

  test "schedules two appointments for the same time" do
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

    visit new_account_appointment_path(@appointment)

    check_list_item_with_name(@held_item1.complete_number)
    check_list_item_with_name(@borrowed_item1.complete_number)
    select_first_available_date
    fill_in_optional_field("First appointment")
    click_on "Schedule Appointment"
    assert_content "Your appointment was scheduled"

    visit new_account_appointment_path(@appointment)
    check_list_item_with_name(@held_item2.complete_number)
    check_list_item_with_name(@borrowed_item2.complete_number)
    select_first_available_date

    fill_in_optional_field("Second appointment")
    click_on "Schedule Appointment"

    assert_text "existing appointment"
    assert_selector "li.appointment", count: 1

    assert_text @held_item1.complete_number
    assert_text @held_item2.complete_number
    assert_text @borrowed_item1.complete_number
    assert_text @borrowed_item2.complete_number
    assert_text "First appointment"
    assert_text "Second appointment"
  end
end
