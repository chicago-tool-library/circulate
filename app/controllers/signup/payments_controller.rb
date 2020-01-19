module Signup
  class PaymentsController < BaseController
    before_action :load_member
    before_action :set_raven_context

    def new
      @payment = Payment.new
      activate_step(:payment)
    end

    def create
      @payment = Payment.new(payment_params)
      unless @payment.valid?
        activate_step(:payment)
        render :new, status: :unprocessable_entity
        return
      end

      result = checkout.checkout_url(amount: @payment.amount, email: @member.email, return_to: callback_signup_payments_url, member_id: @member.id)
      if result.success?
        redirect_to result.value
      else
        errors = result.error
        Rails.logger.error(errors)
        Raven.capture_message(errors.inspect)
        flash[:error] = "There was a problem connecting to our payment processor."
        redirect_to new_signup_payment_url
      end
    end

    def skip
      # completing in person
      MemberMailer.with(member: @member).welcome_message.deliver_later
      reset_session
      redirect_to signup_confirmation_url
    end

    def callback
      transaction_id = params[:transactionId]
      result = checkout.fetch_transaction(member: @member, transaction_id: transaction_id)
      session[:attempts] ||= 0

      if result.success?
        amount = result.value
        Membership.create_for_member(@member, amount: amount, square_transaction_id: transaction_id, source: "square")
        MemberMailer.with(member: @member, amount: amount.cents).welcome_message.deliver_later

        reset_session
        session[:amount] = amount.cents

        redirect_to signup_confirmation_url
        return
      end

      errors = result.error

      if errors.first[:code] == "NOT_FOUND"
        # Give Square a little while for the transaction data to be available
        session[:attempts] += 1
        if session[:attempts] <= 10
          render :wait, layout: nil
          return
        end
      end

      Rails.logger.error(errors)
      Raven.capture_message(errors.inspect)
      reset_session
      flash[:error] = "There was an error processing your payment. Please come into the library to complete signup."
      redirect_to signup_confirmation_url
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

    def set_raven_context
      Raven.extra_context(session)
    end
  end
end
