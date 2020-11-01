require "application_system_test_case"

class AppointmentsTest < ApplicationSystemTestCase
  setup do
    @item1 = create(:item)
    @item2 = create(:item)

    @member = create(:verified_member_with_membership)
    login_as @member.user
  end

  def check_row_with_name(item_name)
    row = find("tr", text: item_name)
    within row do
      find("input[type=checkbox]").check
    end
  end

  test "schedules an appointment" do
    create(:hold, item: @item1, member: @member)
    create(:hold, item: @item2, member: @member)

    visit account_home_url    

    click_on "Schedule a Pick Up"

    assert_text "Schedule an Appointment"

    check_row_with_name(@item1.complete_number) 
    check_row_with_name(@item2.complete_number)

    first_optgroup = find("#appointment_time_range_string optgroup", match: :first)
    selected_date = first_optgroup.value
    first_optgroup.find("option", match: :first).select_option

    fill_in "Tell us about the project you are working on", with: "Just a small project"
    click_on "Create Appointment"

    assert_text "Upcoming Appointments"
    assert_text selected_date
    assert_text @item1.complete_number
    assert_text @item2.complete_number
  end
end