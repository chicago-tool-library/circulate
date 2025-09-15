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
      @borrow_policy_approval.assign_attributes(borrow_policy_params)
      status_has_changed = @borrow_policy_approval.status_changed?
      @borrow_policy_approval.save!

      send_status_change_email if status_has_changed
      redirect_to admin_borrow_policy_borrow_policy_approvals_path(@borrow_policy), status: :see_other, success: "Successfully updated Borrow Policy Approval"
    end

    def create
      @borrow_policy_approval = @borrow_policy.borrow_policy_approvals.create!(
        status: "approved",
        member_id: params[:member_id]
      )
      send_status_change_email
      redirect_to request.referrer.presence || admin_borrow_policy_borrow_policy_approvals_path(@borrow_policy),
        status: :see_other,
        success: "Successfully approved member to borrow #{@borrow_policy.name} items"
    end

    private

    def send_status_change_email
      mailer = BorrowPolicyApprovalMailer.with(borrow_policy_approval: @borrow_policy_approval)

      case @borrow_policy_approval.status
      when BorrowPolicyApproval.statuses[:approved]
        mailer.approved.deliver_later
      when BorrowPolicyApproval.statuses[:rejected]
        mailer.rejected.deliver_later
      when BorrowPolicyApproval.statuses[:revoked]
        mailer.revoked.deliver_later
      end
    end

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
