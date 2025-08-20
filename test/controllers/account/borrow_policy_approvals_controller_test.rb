require "test_helper"

module Account
  class BorrowPolicyApprovalsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup do
      @borrow_policy = create(:borrow_policy, :requires_approval)
      @item = create(:item, borrow_policy: @borrow_policy)
      @member = create(:verified_member_with_membership, created_at: 1.year.ago)
      @user = create(:user, member: @member)
      sign_in @user
    end

    test "creates a borrow policy approval for the borrow policy when one doesn't already exist" do
      assert_difference("BorrowPolicyApproval.count", 1) do
        post account_borrow_policy_approvals_url, params: {item_id: @item.id, borrow_policy_id: @borrow_policy.id}
      end

      borrow_policy_approval = BorrowPolicyApproval.last!
      assert_equal @member, borrow_policy_approval.member
      assert_equal @borrow_policy, borrow_policy_approval.borrow_policy
      assert_equal "requested", borrow_policy_approval.status
      assert flash[:success].present?
      assert flash[:error].blank?
    end

    test "does not create a borrow policy approval when one already exists" do
      create(:borrow_policy_approval, borrow_policy: @borrow_policy, member: @member)

      assert_difference("BorrowPolicyApproval.count", 0) do
        post account_borrow_policy_approvals_url, params: {item_id: @item.id, borrow_policy_id: @borrow_policy.id}
      end

      assert flash[:success].blank?
      assert flash[:error].present?
    end

    test "does not create borrow policy approval when the member is new" do
      @member.update!(created_at: 1.day.ago)

      assert_difference("BorrowPolicyApproval.count", 0) do
        post account_borrow_policy_approvals_url, params: {item_id: @item.id, borrow_policy_id: @borrow_policy.id}
      end

      assert flash[:success].blank?
      assert flash[:error].present?
    end
  end
end
