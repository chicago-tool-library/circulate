require "application_system_test_case"

module Account
  class ForLaterListItemsTest < ApplicationSystemTestCase
    setup do
      @member = create(:verified_member_with_membership)
      login_as @member.user
    end

    def self.test_with_for_later_list_items_enabled(test_name, &)
      test(test_name) do
        FeatureFlags.stub(:for_later_lists_enabled?, true) do
          instance_eval(&)
        end
      end
    end

    test_with_for_later_list_items_enabled "members can see a paginated list of their for later listed items" do
      ignored_for_later_list_item = create(:for_later_list_item)
      for_later_list_items = create_list(:for_later_list_item, 3, member: @member)

      visit account_for_later_list_items_path

      refute_text ignored_for_later_list_item.item.name

      for_later_list_items.each do |for_later_list_item|
        assert_text for_later_list_item.item.name
      end

      assert_css ".pagy-bootstrap"
    end

    test_with_for_later_list_items_enabled "members that are not signed in cannot add anything to their for later list on the item details page" do
      logout
      visit item_path(create(:item))

      refute_text "Save for later"
      refute_text "Don't need it"
    end

    test_with_for_later_list_items_enabled "members that are not signed in cannot add anything to their for later list on the items index page" do
      logout
      create(:item)
      visit items_path

      refute_text "Save for later"
      refute_text "Don't need it"
    end

    test_with_for_later_list_items_enabled "members can see that they've previously for later listed an item on the item details page" do
      for_later_list_item = create(:for_later_list_item, member: @member)

      visit item_path(for_later_list_item.item)

      assert_text "Don't need it"
    end

    test_with_for_later_list_items_enabled "members can see that they've previously for later listed an item on the items index page" do
      create(:for_later_list_item, member: @member)

      visit items_path

      assert_text "Don't need it"
    end

    test_with_for_later_list_items_enabled "members can add an item to their for later list from the item details page" do
      item = create(:item)

      visit item_path(item)

      assert_difference("@member.for_later_list_items.count", 1) do
        click_button "Save for later"
        assert_text "Don't need it"
      end

      for_later_list_item = @member.for_later_list_items.first!

      assert_equal item, for_later_list_item.item
    end

    test_with_for_later_list_items_enabled "members can add an item to their for later list from the items index" do
      item = create(:item)

      visit items_path

      assert_difference("@member.for_later_list_items.count", 1) do
        click_button "Save for later"
        assert_text "Don't need it"
      end

      for_later_list_item = @member.for_later_list_items.first!

      assert_equal item, for_later_list_item.item
    end

    test_with_for_later_list_items_enabled "members can remove an item from their for later list from the for later list page" do
      for_later_list_item, ignored_for_later_list_item = create_list(:for_later_list_item, 2, member: @member)

      visit account_for_later_list_items_path

      assert_text for_later_list_item.item.name
      assert_text ignored_for_later_list_item.item.name

      within("##{dom_id(for_later_list_item)}") do
        click_button "Don't need it"
      end

      refute_text for_later_list_item.item.name
      assert_text ignored_for_later_list_item.item.name
    end

    test_with_for_later_list_items_enabled "members can remove an item from their for later list from the item details page" do
      for_later_list_item = create(:for_later_list_item, member: @member)

      visit item_path(for_later_list_item.item)

      assert_difference("@member.for_later_list_items.count", -1) do
        click_button "Don't need it"
        assert_text "Save for later"
      end
    end

    test_with_for_later_list_items_enabled "members can remove an item from their for later list from the items index" do
      create(:for_later_list_item, member: @member)

      visit items_path

      assert_difference("@member.for_later_list_items.count", -1) do
        click_button "Don't need it"
        assert_text "Save for later"
      end
    end
  end
end
