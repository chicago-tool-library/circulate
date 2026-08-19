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

    test "doesn't create hold for item with holds disabled" do
      @item.update!(holds_enabled: false)

      assert_no_difference("@item.holds.count") do
        post account_holds_url, params: {item_id: @item.id}
      end
      assert_redirected_to item_url(@item.id)
      assert_equal "Can't be placed on hold", flash[:error]
    end

    test "explains when the member has reached the borrow policy limit" do
      borrow_policy = create(:borrow_policy, maximum_items_per_member: 2)
      @item.update!(borrow_policy:)
      checked_out_item = create(:item, borrow_policy:, name: "Cordless Drill")
      held_item = create(:item, borrow_policy:, name: "Folding Table")
      create(:loan, member: @member, item: checked_out_item)
      create(:hold, member: @member, creator: @user, item: held_item)

      assert_no_difference("@item.holds.count") do
        post account_holds_url, params: {item_id: @item.id}
      end

      assert_redirected_to item_url(@item.id)
      follow_redirect!

      assert_select ".toast-error", /You can have a maximum of 2 #{borrow_policy.code}-Tools checked out or on hold at one time\./
      assert_select ".toast-error ul li", 2
      assert_select ".toast-error a[href=?]", item_path(checked_out_item), text: /#{checked_out_item.complete_number}.*Cordless Drill/
      assert_select ".toast-error a[href=?]", item_path(held_item), text: /#{held_item.complete_number}.*Folding Table/
      assert_select ".toast-error li", /checked out/
      assert_select ".toast-error li", /on hold/
      assert_select ".toast-error", /Return or cancel one before placing another hold/
    end

    test "limits the items listed in the borrow policy limit message" do
      borrow_policy = create(:borrow_policy, maximum_items_per_member: 1)
      @item.update!(borrow_policy:)
      staff = create(:staff_user)
      7.times do
        create(:hold, member: @member, creator: staff, item: create(:item, borrow_policy:))
      end

      assert_no_difference("@item.holds.count") do
        post account_holds_url, params: {item_id: @item.id}
      end

      follow_redirect!

      assert_select ".toast-error ul li a", 5
      assert_select ".toast-error ul li", 6
      assert_select ".toast-error ul li:last-child", text: "and 2 more"
    end
  end
end
