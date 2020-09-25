require "test_helper"

class MemberHoldsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @item = create(:item)
    @member = create(:verified_member_with_membership)
    @user = create(:user, member: @member)
    sign_in @user
  end

  test "should create hold for A tool" do
    assert_difference("Hold.count") do
      post member_holds_url, params: {member_hold: {item: @item, member: @member, creator: @user }}
    end

    assert_redirected_to item_url(@item.id)
  end
end
