module Account
  class BorrowPolicyApprovalsController < BaseController
    def create
      borrow_policy = BorrowPolicy.find(params[:borrow_policy_id])

      BorrowPolicyApproval.find_or_create_by!(
        borrow_policy:,
        member: current_user.member
      )

      redirect_to item_path(params[:item_id]), status: :see_other, success: "Approval requested."
    end
  end
end
