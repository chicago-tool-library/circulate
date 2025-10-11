require "test_helper"

module Account
  class WishListItemsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup do
      @user = create(:user)
      @member = create(:member, user: @user)
      sign_in @user
    end

    test "member can wish list an item" do
      item = create(:item)

      post account_wish_list_items_path, params: {wish_list_item: {item_id: item.id}}

      assert_redirected_to item_path(item)
    end

    test "member can wish list an item via turbo stream" do
      item = create(:item)

      post account_wish_list_items_path,
        params: {wish_list_item: {item_id: item.id}},
        as: :turbo_stream

      assert_turbo_stream(action: "replace", target: "wish_list_item_show") do |elements|
        assert_includes elements.to_s, "Remove from Wish List"
      end
    end
  end
end
