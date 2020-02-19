module Account
  class RenewalRequestsController < BaseController
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
        redirect_to account_summary_url(params[:account_id]), success: "Renewal request submitted."
      else
        render_new
      end
    end

    private

    def render_new
      @renewable_loans = @member.loan_summaries.renewable
      @not_renewable_loans = @member.loan_summaries.renewable(false)
      render :new
    end

    def renewal_params
      params.require("renewal_request").permit(loan_ids: [])
    end
  end
end
