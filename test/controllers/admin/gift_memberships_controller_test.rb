require 'test_helper'

module Admin
  class GiftMembershipsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup do
      @item = items(:complete)
      @user = users(:admin)
      sign_in @user
    end

    test "should get index" do
      get admin_gift_memberships_url
      assert_response :success
    end

    test "should get new" do
      get new_admin_gift_membership_url
      assert_response :success
    end

    test "should create gift_membership" do
      assert_difference('GiftMembership.count') do
        post admin_gift_memberships_url, params: { 
          gift_membership: { 
            amount: "44",
            purchaser_email: "someone@somewhere.com",
            purchaser_name: "Gift Giver"
          }
        }
      end

      assert_redirected_to admin_gift_memberships_url
    end

    test "should show gift_membership" do
      gift_membership = create(:gift_membership)
      get admin_gift_membership_url(gift_membership)
      assert_response :success
    end

    test "should get edit" do
      gift_membership = create(:gift_membership)
      get edit_admin_gift_membership_url(gift_membership)
      assert_response :success
    end

    test "should update gift_membership" do
      gift_membership = create(:gift_membership)
      patch admin_gift_membership_url(gift_membership), params: {
        gift_membership: { 
          amount: "44",
          purchaser_email: "someone@somewhere.com",
          purchaser_name: "Gift Giver"
        }
      }
      assert_redirected_to admin_gift_memberships_url
    end

    test "should destroy gift_membership" do
      gift_membership = create(:gift_membership)
      assert_difference('GiftMembership.count', -1) do
        delete admin_gift_membership_url(gift_membership)
      end

      assert_redirected_to admin_gift_memberships_url
    end
  end
end