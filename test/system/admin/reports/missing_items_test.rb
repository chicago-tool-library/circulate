require "application_system_test_case"

class AdminMissingItemsTest < ApplicationSystemTestCase
  setup do
    sign_in_as_admin
  end

  test "shows all of the missing items in the system" do
    first_active_item = create(:item, :active)
    missing_items = create_list(:item, 3, :missing)
    last_active_item = create(:item, :active)

    ticket = create(:ticket, item: missing_items.first)

    create(:ticket_update, ticket:)
    last_ticket_update = create(:ticket_update, ticket:)

    visit admin_reports_missing_items_url

    missing_items.each do |item|
      assert_text item.name
      assert_text item.complete_number
    end

    assert_text "1 ticket"
    assert_text ticket.title
    assert_text last_ticket_update.body.to_plain_text

    [first_active_item, last_active_item].each do |item|
      refute_text item.name
    end
  end
end
