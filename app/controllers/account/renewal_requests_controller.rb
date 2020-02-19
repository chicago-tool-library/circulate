module Account
  class RenewalRequestsController < BaseController
    before_action :load_member

    def new
      @renewal_request = RenewalRequest.new(loan_source: @member.loans)
      render_new
    end

    def create
      @renewal_request = RenewalRequest.new(
        loan_source: @member.loans,
        loan_ids: renewal_params[:loan_ids].reject(&:empty?)
      )

      if @renewal_request.commit
        redirect_to account_member_url(params[:member_id]), success: "Renewal request submitted."
      else
        render_new(:unprocessable_entity)
      end
    end

    private

    def render_new(status = :ok)
      @renewable_loans = @member.loan_summaries.renewable
      @not_renewable_loans = @member.loan_summaries.renewable(false)
      render :new, status: status
    end

    def renewal_params
      params.require("renewal_request").permit(loan_ids: [])
    end

    def load_member
      load_member_from_encrypted_id(params[:member_id])
    end
  end
end
