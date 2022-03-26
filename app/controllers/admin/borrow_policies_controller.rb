module Admin
  class BorrowPoliciesController < BaseController
    before_action :set_borrow_policy, only: [:edit, :update, :destroy]

    def index
      @borrow_policies = BorrowPolicy.alpha_by_code
    end

    def edit
    end

    def update
      if @borrow_policy.update(borrow_policy_params)
        redirect_to admin_borrow_policies_url, success: "Borrow policy was successfully updated."
      else
        render :edit
      end
    end

    private

    def set_borrow_policy
      @borrow_policy = BorrowPolicy.find(params[:id])
    end

    def borrow_policy_params
      params.require(:borrow_policy).permit(:name, :duration, :fine, :fine_period, :uniquely_numbered, :code, :description, :default, :renewal_limit, :member_renewable, :consumable)
    end
  end
end
