module Signup
  class PaymentsController < BaseController
    before_action :load_member

    def new
      result = checkout.checkout_url(amount: Money.new(1000), email: @member.email, return_to: signup_payments_callback_url, member_id: @member.id)
      if result.success?
        redirect_to result.value
      else
        activate_complete_step
        flash.now[:error] = result.errors
      end
    end

    def callback
      result = checkout.record_transaction(member: @member, transaction_id: params[:transactionId])
      if result.success?
        redirect_to signup_confirmation_path
      else
        activate_complete_step
        flash.now[:error] = result.errors
      end
    end
  end

  private def checkout
      SquareCheckout.new(
        access_token: ENV.fetch("SQUARE_ACCESS_TOKEN"),
        location_id: ENV.fetch("SQUARE_LOCATION_ID")
      )
  end
end
