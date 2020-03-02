module Admin
  class BorrowPoliciesController < BaseController
    before_action :set_borrow_policy, only: [:show, :edit, :update, :destroy]

    def index
      @borrow_policies = BorrowPolicy.alpha_by_code
    end

    def edit
    end

    def update
      respond_to do |format|
        if @borrow_policy.update(borrow_policy_params)
          format.html { redirect_to admin_borrow_policies_url, notice: "Borrow policy was successfully updated." }
          format.json { render :show, status: :ok, location: [:admin, @borrow_policy] }
        else
          format.html { render :edit }
          format.json { render json: @borrow_policy.errors, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      @borrow_policy.destroy
      respond_to do |format|
        format.html { redirect_to admin_borrow_policies_url, notice: "Borrow policy was successfully destroyed." }
        format.json { head :no_content }
      end
    end

    private

    def set_borrow_policy
      @borrow_policy = BorrowPolicy.find(params[:id])
    end

    def borrow_policy_params
      params.require(:borrow_policy).permit(:name, :duration, :fine, :fine_period, :uniquely_numbered, :code, :description, :default)
    end
  end
end
