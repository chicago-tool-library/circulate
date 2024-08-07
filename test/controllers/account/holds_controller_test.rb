require "test_helper"

module Account
  class HoldsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup do
      @item = create(:item)
      @member = create(:verified_member_with_membership)
      @user = create(:user, member: @member)
    end

    test "creates hold for an item and starts hold" do
      sign_in @user

      assert_difference("@item.holds.count") do
        post account_holds_url, params: {item_id: @item.id}
      end

      assert_redirected_to item_url(@item.id)

      hold = @item.holds.last
      assert hold.started?
    end

    test "creates hold for an item and doesn't start hold" do
      sign_in @user

      create(:hold, item: @item)

      assert_difference("@item.holds.count") do
        post account_holds_url, params: {item_id: @item.id}
      end

      assert_redirected_to item_url(@item.id)

      hold = @item.holds.last
      refute hold.started?
    end

    test "does not create holds for users that have unconfirmed email addresses" do
      member = create(:member, user: create(:user, :unconfirmed))
      sign_in member.user

      assert_difference("@item.holds.count", 0) do
        post account_holds_url, params: {item_id: @item.id}
      end
    end
  end
end
