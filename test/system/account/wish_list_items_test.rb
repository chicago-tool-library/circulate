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

    test "members that are not signed in cannot add anything to their wishlist on the item details page" do
      logout
      visit item_path(create(:item))

      refute_text "Add to Wish List"
      refute_text "Remove from Wish List"
    end

    test "members that are not signed in cannot add anything to their wishlist on the items index page" do
      logout
      create(:item)
      visit items_path

      refute_text "Add to Wish List"
      refute_text "Remove from Wish List"
    end

    test "members can see that they've previously wish listed an item on the item details page" do
      wish_list_item = create(:wish_list_item, member: @member)

      visit item_path(wish_list_item.item)

      assert_text "Remove from Wish List"
    end

    test "members can see that they've previously wish listed an item on the items index page" do
      create(:wish_list_item, member: @member)

      visit items_path

      assert_text "Remove from Wish List"
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
      item = create(:item)

      visit items_path

      assert_difference("@member.wish_list_items.count", 1) do
        click_button "Add to Wish List"
        assert_text "Remove from Wish List"
      end

      wish_list_item = @member.wish_list_items.first!

      assert_equal item, wish_list_item.item
    end

    test "members can remove an item from their wishlist from the wish list page" do
      wish_list_item, ignored_wish_list_item = create_list(:wish_list_item, 2, member: @member)

      visit account_wish_list_items_path

      assert_text wish_list_item.item.name
      assert_text ignored_wish_list_item.item.name

      within("##{dom_id(wish_list_item)}") do
        click_button "Remove from Wish List"
      end

      refute_text wish_list_item.item.name
      assert_text ignored_wish_list_item.item.name
    end

    test "members can remove an item from their wish list from the item details page" do
      wish_list_item = create(:wish_list_item, member: @member)

      visit item_path(wish_list_item.item)

      assert_difference("@member.wish_list_items.count", -1) do
        click_button "Remove from Wish List"
        assert_text "Add to Wish List"
      end
    end

    test "members can remove an item from their wish list from the items index" do
      create(:wish_list_item, member: @member)

      visit items_path

      assert_difference("@member.wish_list_items.count", -1) do
        click_button "Remove from Wish List"
        assert_text "Add to Wish List"
      end
    end
  end
end
