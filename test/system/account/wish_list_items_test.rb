require "application_system_test_case"

module Account
  class WishListItemsTest < ApplicationSystemTestCase
    setup do
      @member = create(:verified_member_with_membership)
      login_as @member.user
    end

    test "members can see a paginated list of their wish listed items" do
      ignored_wish_list_item = create(:wish_list_item)
      wish_list_items = create_list(:wish_list_item, 3, member: @member)

      visit account_wish_list_items_path

      refute_text ignored_wish_list_item.item.name

      wish_list_items.each do |wish_list_item|
        assert_text wish_list_item.item.name
      end

      assert_css ".pagy-bootstrap"
    end

    test "members can see that they've wish listed an item on the item details page" do
      skip
    end

    test "members can add an item to their wish list from the item details page" do
      item = create(:item)

      visit item_path(item)

      assert_difference("@member.wish_list_items.count", 1) do
        click_button "Add to Wish List"
        assert_text "Remove from Wish List"
      end

      wish_list_item = @member.wish_list_items.first!

      assert_equal item, wish_list_item.item
    end

    test "members can add an item to their wish list from the items index" do
      skip
    end

    test "members can remove an item from their wishlist from the wish list page" do
      skip
    end

    test "members can remove an item from their wish list from the item details page" do
      skip
    end

    test "members can remove an item from their wish list from the items index" do
      skip
    end
  end
end
