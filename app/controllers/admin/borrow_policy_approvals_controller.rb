module Admin
  class BorrowPolicyApprovalsController < BaseController
    include Pagy::Backend
    before_action :set_borrow_policy
    before_action :set_borrow_policy_approval, only: %i[edit update]

    def index
      @q = @borrow_policy.borrow_policy_approvals.order(created_at: :desc).ransack(params[:q])
      @pagy, @borrow_policy_approvals = pagy(@q.result.includes(:member))
    end

    def edit
    end

    def update
      @borrow_policy_approval.update!(borrow_policy_params)
      redirect_to admin_borrow_policy_borrow_policy_approvals_path(@borrow_policy), status: :see_other, success: "Successfully updated Borrow Policy Approval"
    end

    private

    def set_borrow_policy
      @borrow_policy = BorrowPolicy.find(params[:borrow_policy_id])
    end

    def set_borrow_policy_approval
      @borrow_policy_approval = @borrow_policy.borrow_policy_approvals.find(params[:id])
    end

    def borrow_policy_params
      params.require(:borrow_policy_approval).permit(:status, :status_reason)
    end
  end
end
