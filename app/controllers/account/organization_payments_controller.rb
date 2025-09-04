module Account
  class OrganizationPaymentsController < BaseController
    def new
    end

    def create
      result = checkout.checkout_url(amount: Money.new(500), email: "test@esample.com", return_to: callback_account_organization_payments_url)
      if result.success?
        redirect_to result.value, status: :see_other, allow_other_host: true
      else
        errors = result.error
        Rails.logger.error(errors)
        flash[:error] = "There was a problem connecting to our payment processor."
        redirect_to new_account_organization_payment_url, status: :see_other
      end
    end

    def callback
      @result = checkout.fetch_session(session_id: params[:session_id])
    end

    def index
    end

    private

    # def form_params
    #   params.require(:membership_payment_form).permit(:amount_dollars)
    # end

    def checkout
      StripeCheckout.new(ENV.fetch("STRIPE_API_KEY"), environment: Rails.env)
    end
  end
end
