# Preview all emails at http://localhost:3000/rails/mailers/borrow_policy_approval_mailer
class BorrowPolicyApprovalMailerPreview < ActionMailer::Preview
  def approved
    borrow_policy_approval = borrow_policy_approval(BorrowPolicyApproval.statuses[:approved])
    BorrowPolicyApprovalMailer.with(borrow_policy_approval:).approved
  end

  def rejected
    borrow_policy_approval = borrow_policy_approval(BorrowPolicyApproval.statuses[:rejected])
    BorrowPolicyApprovalMailer.with(borrow_policy_approval:).rejected
  end

  def revoked
    borrow_policy_approval = borrow_policy_approval(BorrowPolicyApproval.statuses[:revoked])
    BorrowPolicyApprovalMailer.with(borrow_policy_approval:).revoked
  end

  private

  def borrow_policy_approval(status)
    library = Library.first!
    borrow_policy = BorrowPolicy.find_by(requires_approval: true, library:)

    borrow_policy_approval = BorrowPolicyApproval
      .create_with(member: Member.find_by!(library:))
      .find_or_create_by(borrow_policy:)

    borrow_policy_approval.update!(status:)

    borrow_policy_approval
  end
end
