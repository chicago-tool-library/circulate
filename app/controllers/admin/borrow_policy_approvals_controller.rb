module Admin
  class BorrowPolicyApprovalsController < BaseController
    before_action :set_borrow_policy, only: [:index]

    def index
      @q = @borrow_policy.borrow_policy_approvals.order(created_at: :desc).ransack(params[:q])
      @borrow_policy_approvals = @q.result.includes(:member)
    end

    private

    def set_borrow_policy
      @borrow_policy = BorrowPolicy.find(params[:borrow_policy_id])
    end
  end
end
