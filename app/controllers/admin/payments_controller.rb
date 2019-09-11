module Admin
  class PaymentsController < BaseController
    before_action :load_member

    def new
      @amount_due = default_payment_value
      @payment = Payment.new(amount_dollars: @amount_due)
    end

    def create
      @payment = Payment.new(payment_params)

      if @payment.valid?
        Adjustment.record_member_payment(@member, @payment.amount, @payment.payment_source)
        redirect_to admin_member_path(@member), success: "Payment recorded."
      else
        @amount_due = default_payment_value
        render :new
      end
    end

    private

    def load_member
      @member = Member.find(params[:member_id])
    end

    def default_payment_value
      Money.new([-@member.account_balance, 0].max)
    end

    def payment_params
      params.require(:admin_payment).permit(:amount_dollars, :payment_source)
    end
  end
end