module Admin
  class MembershipsController < BaseController
    before_action :load_member

    def index
      @memberships = @member.memberships
    end

    def new
      @payment = Payment.new
    end

    def create
      if params[:without_payment]
        Membership.create_for_member(@member)
        redirect_to admin_member_path(@member), success: "Membership created."
        return
      end

      @payment = Payment.new(payment_params)
      if @payment.valid?
        Membership.create_for_member(@member, amount: @payment.amount, source: @payment.payment_source)
        redirect_to admin_member_path(@member), success: "Membership created."
      else
        render :new
      end
    end

    private

    def load_member
      @member = Member.find(params[:member_id])
    end

    def payment_params
      params.require(:admin_payment).permit(:amount_dollars, :payment_source)
    end
  end
end
