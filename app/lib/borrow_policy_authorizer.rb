module BorrowPolicyAuthorizer
  NUMBER_OF_MONTHS = 2

  Result = Struct.new(:borrow_policy, :member, :borrow_policy_approval, keyword_init: true) do
    def can_request?
      reasons_why_cannot_request.empty?
    end

    def reasons_why_cannot_request
      reasons = []

      reasons << "must be a member for more than #{NUMBER_OF_MONTHS} months" if member_too_new?
      reasons << "member is already approved" if borrow_policy_approval&.approved?
      reasons << "member already has a pending request" if borrow_policy_approval&.requested?
      reasons << "request was rejected in the last #{NUMBER_OF_MONTHS} months" if borrow_policy_approval&.rejected? && approval_recently_updated?
      reasons << "approval was revoked in the last #{NUMBER_OF_MONTHS} months" if borrow_policy_approval&.revoked? && approval_recently_updated?

      reasons
    end

    private

    def member_too_new?
      member.created_at > NUMBER_OF_MONTHS.months.ago
    end

    def approval_recently_updated?
      borrow_policy_approval.updated_at > NUMBER_OF_MONTHS.months.ago
    end
  end

  class << self
    def check(borrow_policy:, member:, borrow_policy_approval: nil)
      borrow_policy_approval ||= BorrowPolicyApproval.find_by(borrow_policy:, member:)
      Result.new(borrow_policy:, member:, borrow_policy_approval:)
    end
  end
end
