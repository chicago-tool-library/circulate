require "application_system_test_case"
class MainteneenceTicketsTest < ApplicationSystemTestCase
  def setup
    sign_in_as_admin

    audited_as_admin do
      @item = create(:item)
    end
  end

  def add_tags(tags)
    find(".selectize-control").click
    tags.each do |tag|
      page.find("input[id='ticket_tag_list-selectized']").native.type(tag + "\n")
    end
  end

  def assert_tags(tags)
    tags.each do |tag|
      assert_selector ".chip", text: tag
    end
  end

  test "creates a ticket" do
    tags = %w[one two three]

    visit admin_item_tickets_url(@item)
    click_on "Create New Ticket"

    assert_selector "h1", text: "New Ticket"

    fill_in "Title", with: "It's busted"
    fill_in_rich_text_area "Body", with: "Needs parts"

    select "Parts on Order", from: "Ticket Status"

    add_tags tags

    click_on "Create Ticket"

    assert_selector "h2", text: "It's busted"
    within ".card-body" do
      assert_content "Needs parts"
    end
    assert_selector ".chip", text: "Parts on Order"

    within ".item-panel" do
      assert_selector ".item-checkout-status", text: "Maintenance"
    end

    assert_tags tags
  end
  test "marks an item as in maintenance by creating a ticket" do
    tags = %w[one two three]

    visit admin_item_tickets_url(@item)
    click_on "Create New Ticket"

    assert_selector "h1", text: "New Ticket"

    fill_in "Title", with: "It's busted"
    fill_in_rich_text_area "Body", with: "Some more information"

    select "Retired (removed from inventory)", from: "Ticket Status"
    select "Broken (returned in a not working state)", from: "Reason"

    add_tags tags

    click_on "Create Ticket"

    assert_selector "h2", text: "It's busted"
    within ".card-body" do
      assert_content "Some more information"
    end
    assert_selector ".chip", text: "Retired"

    within ".item-panel" do
      assert_selector ".item-checkout-status", text: "Retired (Broken)"
    end

    assert_tags tags
  end

  test "marks an item as in maintenance by creating a ticket update" do
    visit admin_item_tickets_url(@item)
    click_on "Create New Ticket"

    assert_selector "h1", text: "New Ticket"

    fill_in "Title", with: "It's busted"
    fill_in_rich_text_area "Body", with: "Needs parts"

    select "Parts on Order", from: "Ticket Status"

    click_on "Create Ticket"

    assert_selector "h2", text: "It's busted"
    within ".card-body" do
      assert_content "Needs parts"
    end
    assert_selector ".chip", text: "Parts on Order"

    within ".item-panel" do
      assert_selector ".item-checkout-status", text: "Maintenance"
    end

    click_on "Add Update"
    fill_in_rich_text_area "Body", with: "Parts aren't available"

    select "Retired (removed from inventory)", from: "Change Ticket Status"
    select "Broken (returned in a not working state)", from: "Reason"

    click_on "Save"

    assert_selector ".chip", text: "Retired"
    assert_content "updated this ticket's status to Retired"

    within ".item-panel" do
      assert_selector ".item-checkout-status", text: "Retired (Broken)"
    end
  end
end
