require "test_helper"

module Account
  class HoldsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup do
      @item = create(:item)
      @member = create(:verified_member_with_membership)
      @user = create(:user, member: @member)
      sign_in @user
    end

    test "creates hold for an item and starts hold" do
      assert_difference("@item.holds.count") do
        post account_holds_url, params: {item_id: @item.id}
      end

      assert_redirected_to item_url(@item.id)

      hold = @item.holds.last
      assert hold.started?
    end

    test "creates hold for an item and doesn't start hold" do
      create(:hold, item: @item)

      assert_difference("@item.holds.count") do
        post account_holds_url, params: {item_id: @item.id}
      end

      assert_redirected_to item_url(@item.id)

      hold = @item.holds.last
      refute hold.started?
    end
  end
end
