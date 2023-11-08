module Renewal
  class PaymentsController < BaseController
    before_action :load_member
    before_action :are_payments_enabled?

    def new
      @form = MembershipPaymentForm.new
      @amount = @member.last_membership&.amount || Money.new(0)
      activate_step(:payment)
    end

    def create
      @form = MembershipPaymentForm.new(form_params)
      unless @form.valid?
        @amount = @member.last_membership&.amount || Money.new(0)
        activate_step(:payment)
        render :new, status: :unprocessable_entity
        return
      end

      result = checkout.checkout_url(amount: @form.amount, email: @member.email, return_to: callback_renewal_payments_url, member_id: @member.id, date: Date.current)
      if result.success?
        redirect_to result.value, status: :see_other, allow_other_host: true
      else
        errors = result.error
        Rails.logger.error(errors)
        flash[:error] = "There was a problem connecting to our payment processor."
        redirect_to new_renewal_payment_url, status: :see_other
      end
    end

    def skip
      # completing in person
      MemberMailer.with(member: @member).renewal_message.deliver_later
      redirect_to renewal_confirmation_url, status: :see_other
    end

    def callback
      transaction_id = params[:transactionId]
      result = checkout.fetch_transaction(member: @member, transaction_id: transaction_id)
      session[:attempts] ||= 0

      if result.success?
        amount = result.value
        Membership.create_for_member(@member, amount: amount, start_membership: true, square_transaction_id: transaction_id, source: "square")
        MemberMailer.with(member: @member, amount: amount.cents).renewal_message.deliver_later

        session[:amount] = amount.cents

        redirect_to renewal_confirmation_url, status: :see_other
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
      reset_session
      flash[:error] = "There was an error processing your payment. Please come into the library to complete signup."
      redirect_to renewal_confirmation_url, status: :see_other
    end

    private

    def form_params
      params.require(:membership_payment_form).permit(:amount_dollars)
    end

    def checkout
      SquareCheckout.new(
        access_token: ENV.fetch("SQUARE_ACCESS_TOKEN"),
        location_id: ENV.fetch("SQUARE_LOCATION_ID"),
        environment: ENV.fetch("SQUARE_ENVIRONMENT")
      )
    end

    def are_payments_enabled?
      if !@current_library.allow_payments?
        render_not_found
      end
    end
  end
end
