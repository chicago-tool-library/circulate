require "application_system_test_case"

class AdminSearchesTest < ApplicationSystemTestCase
  setup do
    sign_in_as_admin
  end

  test "lists a member by number (exact by default)" do
    member = create(:verified_member)
    other_member = create(:verified_member)

    visit admin_dashboard_path
    fill_in "query", with: "#{member.number}\n"

    assert_text member.email
    refute_text other_member.email

    fill_in "query", with: "#{member.number}123\n"

    refute_text member.email
    refute_text other_member.email
    assert_text "No member with number"
  end

  test "lists an item by number (exact by default)" do
    item = create(:item)
    other_item = create(:item)

    visit admin_dashboard_path
    fill_in "query", with: "#{item.number}\n"

    assert_text item.name
    refute_text other_item.name

    fill_in "query", with: "#{item.number}123\n"

    refute_text item.name
    refute_text other_item.name
    assert_text "No item with number"
  end

  test "lists items that match anything" do
    drill = create(:item, name: "Power Drill")
    saw = create(:item, name: "Power Saw")
    sander = create(:item, name: "Power Sander")

    visit admin_dashboard_path
    fill_in "query", with: "Power Sa\n"

    refute_text drill.name
    assert_text saw.name
    assert_text sander.name
  end

  test "items list can be filtered by available" do
    drill = create(:item, :active, name: "Power Drill")
    saw = create(:item, :maintenance, name: "Power Saw")
    sander = create(:item, :active, name: "Power Sander")

    visit admin_dashboard_path
    fill_in "query", with: "Power\n"

    assert_text drill.name
    assert_text sander.name
    assert_text saw.name

    find("label", text: "Only show items available now").click # check available only

    refute_text saw.name
    assert_text drill.name
    assert_text sander.name

    find("label", text: "Only show items available now").click # uncheck available only

    assert_text drill.name
    assert_text sander.name
    assert_text saw.name
  end

  test "lists members that match anything" do
    jamie_surname = create(:verified_member, full_name: "Jamie Surname")
    jamie = create(:verified_member, preferred_name: "Jamie")
    parker = create(:verified_member, full_name: "Parker Car")

    visit admin_dashboard_path
    fill_in "query", with: "Jami\n"

    assert_text jamie_surname.email
    assert_text jamie.email
    refute_text parker.email
  end
end
