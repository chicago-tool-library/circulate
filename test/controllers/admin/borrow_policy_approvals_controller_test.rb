require "test_helper"

module Admin
  class BorrowPolicyApprovalsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup do
      @user = create(:admin_user)
      @borrow_policy_approval = create(:borrow_policy_approval, :requested)
      @borrow_policy = @borrow_policy_approval.borrow_policy
      @member = @borrow_policy_approval.member
      sign_in @user
    end

    test "update sends an email when updating to approved" do
      assert_emails(1) do
        patch(
          admin_borrow_policy_borrow_policy_approval_path(@borrow_policy, @borrow_policy_approval),
          params: {borrow_policy_approval: {status: "approved"}}
        )
      end

      assert_equal "approved", @borrow_policy_approval.reload.status

      mail = ActionMailer::Base.deliveries.last

      assert_equal [@member.email], mail.to
      assert_includes mail.subject, "have been approved to borrow"
    end

    test "update sends an email when updating to rejected" do
      assert_emails(1) do
        patch(
          admin_borrow_policy_borrow_policy_approval_path(@borrow_policy, @borrow_policy_approval),
          params: {borrow_policy_approval: {status: "rejected"}}
        )
      end

      assert_equal "rejected", @borrow_policy_approval.reload.status

      mail = ActionMailer::Base.deliveries.last

      assert_equal [@member.email], mail.to
      assert_includes mail.subject, "have not been approved to borrow"
    end

    test "update sends an email when updating to revoked" do
      assert_emails(1) do
        patch(
          admin_borrow_policy_borrow_policy_approval_path(@borrow_policy, @borrow_policy_approval),
          params: {borrow_policy_approval: {status: "revoked"}}
        )
      end

      assert_equal "revoked", @borrow_policy_approval.reload.status

      mail = ActionMailer::Base.deliveries.last

      assert_equal [@member.email], mail.to
      assert_includes mail.subject, "no longer borrow"
    end

    test "update does not send an email when updating to requested" do
      assert_emails(0) do
        patch(
          admin_borrow_policy_borrow_policy_approval_path(@borrow_policy, @borrow_policy_approval),
          params: {borrow_policy_approval: {status: "requested"}}
        )
      end
    end

    test "update does not send an email when the status has not been changed" do
      @borrow_policy_approval.update!(status: "approved")
      assert_emails(0) do
        patch(
          admin_borrow_policy_borrow_policy_approval_path(@borrow_policy, @borrow_policy_approval),
          params: {borrow_policy_approval: {status: "approved"}}
        )
      end
    end
  end
end
