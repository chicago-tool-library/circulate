require "test_helper"

module Admin
  class BorrowPoliciesControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup do
      @user = create(:admin_user)
      sign_in @user
    end

    test "should get index" do
      get admin_borrow_policies_url
      assert_response :success
    end

    test "should get edit" do
      @borrow_policy = create(:default_borrow_policy)
      get edit_admin_borrow_policy_url(@borrow_policy)
      assert_response :success
    end

    test "should redirect to admin borrow policies page" do
      @borrow_policy = create(:default_borrow_policy)

      patch admin_borrow_policy_url(@borrow_policy), params: {borrow_policy: {duration: @borrow_policy.duration, fine_cents: @borrow_policy.fine_cents, fine_period: @borrow_policy.fine_period, name: @borrow_policy.name, code: "Q"}}

      assert_redirected_to admin_borrow_policies_url
    end

    test "should update borrow_policy" do
      @borrow_policy = create(:default_borrow_policy)
      patch admin_borrow_policy_url(@borrow_policy), params: {borrow_policy: {duration: 10, fine: 8.23, fine_period: 26, name: "New name", code: "Q", member_renewable: true, requires_approval: true}}

      @borrow_policy.reload
      assert_equal 10, @borrow_policy.duration
      assert_equal 823, @borrow_policy.fine_cents
      assert_equal 26, @borrow_policy.fine_period
      assert_equal "New name", @borrow_policy.name
      assert_equal "Q", @borrow_policy.code
      assert_equal true, @borrow_policy.member_renewable
      assert_equal true, @borrow_policy.requires_approval
    end
  end
end
