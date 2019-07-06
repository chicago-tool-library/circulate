module Signup
  class PaymentsController < BaseController
    before_action :load_member

    def new
      @payment = Payment.new
      activate_payment_step
    end

    def create
      @payment = Payment.new(payment_params)
      unless @payment.valid?
        activate_payment_step
        render :new, status: :unprocessable_entity
        return
      end

      result = checkout.checkout_url(amount: @payment.amount, email: @member.email, return_to: signup_payments_callback_url, member_id: @member.id)
      if result.success?
        redirect_to result.value
      else
        activate_complete_step
        flash[:error] = result.errors
        redirect_to new_signup_payment_path
      end
    end

    def callback
      result = checkout.record_transaction(member: @member, transaction_id: params[:transactionId])
      if result.success?
        redirect_to signup_confirmation_path
      else
        flash[:error] = result.errors
        redirect_to :new
      end
    end

    private

    def payment_params
      params.require(:signup_payment).permit(:amount_dollars)
    end

    def checkout
      SquareCheckout.new(
        access_token: ENV.fetch("SQUARE_ACCESS_TOKEN"),
        location_id: ENV.fetch("SQUARE_LOCATION_ID")
      )
    end
  end
end
