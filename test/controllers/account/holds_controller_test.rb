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

    test "should create hold for A tool" do
      assert_difference("Hold.count") do
        post account_holds_url, params: {item_id: @item.id}
      end

      assert_redirected_to item_url(@item.id)
    end
  end
end
