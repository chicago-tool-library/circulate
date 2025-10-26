require "test_helper"

module Account
  class WishListItemsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup do
      @user = create(:user)
      @member = create(:member, user: @user)
      sign_in @user
    end

    def self.test_with_wish_items_enabled(test_name, &)
      test(test_name) do
        FeatureFlags.stub(:wish_lists_enabled?, true) do
          instance_eval(&)
        end
      end
    end

    test_with_wish_items_enabled "member can wish list an item" do
      item = create(:item)

      post account_wish_list_items_path, params: {wish_list_item: {item_id: item.id}}

      assert_redirected_to item_path(item)
    end

    test_with_wish_items_enabled "member can wish list an item via turbo stream" do
      item = create(:item)

      post account_wish_list_items_path,
        params: {wish_list_item: {item_id: item.id}},
        as: :turbo_stream

      assert_turbo_stream(action: "replace", target: "wish_list_item_show") do |elements|
        assert_includes elements.to_s, "wish_list_item_show"
        assert_includes elements.to_s, "Don't need it"
      end

      assert_turbo_stream(action: "replace", target: "#{dom_id(item)}_wish_list_items_index") do |elements|
        assert_includes elements.to_s, "#{dom_id(item)}_wish_list_items_index"
        assert_includes elements.to_s, "Don't need it"
      end
    end

    test_with_wish_items_enabled "member can remove a wish list item" do
      create(:wish_list_item, member: @member) # ignored
      wish_list_item = create(:wish_list_item, member: @member)

      assert_difference("WishListItem.count", -1) do
        delete account_wish_list_item_path(wish_list_item)
      end

      assert_redirected_to account_wish_list_items_path
    end

    test_with_wish_items_enabled "member can remove a wish list item via turbo stream" do
      create(:wish_list_item, member: @member) # ignored
      wish_list_item = create(:wish_list_item, member: @member)
      item = wish_list_item.item

      delete account_wish_list_item_path(wish_list_item), as: :turbo_stream

      assert_turbo_stream(action: "remove", target: dom_id(wish_list_item))

      assert_turbo_stream(action: "replace", target: "wish_list_item_show") do |elements|
        assert_includes elements.to_s, "wish_list_item_show"
        assert_includes elements.to_s, "Save for later"
      end

      assert_turbo_stream(action: "replace", target: "#{dom_id(item)}_wish_list_items_index") do |elements|
        assert_includes elements.to_s, "#{dom_id(item)}_wish_list_items_index"
        assert_includes elements.to_s, "Save for later"
      end
    end
  end
end
