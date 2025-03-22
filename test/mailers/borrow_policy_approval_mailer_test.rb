require "application_system_test_case"

class BorrowPolicyApprovalMailerTest < ApplicationSystemTestCase
  include Lending

  setup do
    ActionMailer::Base.deliveries.clear
  end

  test "can deliver an email when approval has been approved" do
    borrow_policy_approval = create(:borrow_policy_approval, :approved)
    member = borrow_policy_approval.member
    borrow_policy = borrow_policy_approval.borrow_policy

    email = BorrowPolicyApprovalMailer.with(borrow_policy_approval:).approved

    assert_emails(1) { email.deliver_now }

    assert_delivered_email(to: member.email) do |text, html, _, subject|
      assert_equal "You have been approved to borrow #{borrow_policy.code} #{borrow_policy.name} tools", subject
      assert_includes text, "approved", "mail should include the approval status in text part"
      assert_includes html, "approved", "mail should include the approval status in html part"
    end
  end

  test "can deliver an email when approval has been rejected" do
    borrow_policy_approval = create(:borrow_policy_approval, :rejected)
    member = borrow_policy_approval.member
    borrow_policy = borrow_policy_approval.borrow_policy

    email = BorrowPolicyApprovalMailer.with(borrow_policy_approval:).rejected

    assert_emails(1) { email.deliver_now }

    assert_delivered_email(to: member.email) do |text, html, _, subject|
      assert_equal "You have not been approved to borrow #{borrow_policy.code} #{borrow_policy.name} tools at this time", subject
      assert_includes text, "not been approved", "mail should include the approval status in text part"
      assert_includes html, "not been approved", "mail should include the approval status in html part"
    end
  end

  test "can deliver an email when approval has been revoked" do
    borrow_policy_approval = create(:borrow_policy_approval, :revoked)
    member = borrow_policy_approval.member
    borrow_policy = borrow_policy_approval.borrow_policy

    email = BorrowPolicyApprovalMailer.with(borrow_policy_approval:).revoked

    assert_emails(1) { email.deliver_now }

    assert_delivered_email(to: member.email) do |text, html, _, subject|
      assert_equal "You may no longer borrow #{borrow_policy.code} #{borrow_policy.name} tools", subject
      assert_includes text, "no longer approved to borrow", "mail should include the approval status in text part"
      assert_includes html, "no longer approved to borrow", "mail should include the approval status in html part"
    end
  end
end
