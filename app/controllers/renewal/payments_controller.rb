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
        Appsignal.set_error(result.error)
        Rails.logger.error(result.error)
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
      session[:payment] = true
      redirect_to renewal_confirmation_url, status: :see_other
    end

    private

    def form_params
      params.require(:membership_payment_form).permit(:amount_dollars)
    end

    def checkout
      SquareCheckout::Client.from_env
    end

    def are_payments_enabled?
      if !@current_library.allow_payments?
        render_not_found
      end
    end
  end
end
