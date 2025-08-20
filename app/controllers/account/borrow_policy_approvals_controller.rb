module Account
  class BorrowPolicyApprovalsController < BaseController
    def create
      borrow_policy = BorrowPolicy.find(params[:borrow_policy_id])
      result = BorrowPolicyAuthorizer.check(borrow_policy:, member: current_member)

      if result.can_request?
        BorrowPolicyApproval.create!(borrow_policy:, member: current_user.member)

        redirect_to request.referrer.presence || root_path, status: :see_other, success: "Approval requested."
      else
        redirect_to request.referrer.presence || root_path, status: :see_other, error: result.reasons_why_cannot_request.join(", ").capitalize
      end
    end
  end
end
