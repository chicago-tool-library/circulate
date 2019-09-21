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
      @payment = Payment.new(payment_params)

      if @payment.valid?
        membership = @member.memberships.create!(started_on: Time.current.to_date, ended_on: Time.current.to_date + 364.days)
        Adjustment.record_membership(membership, @payment.amount)
        Adjustment.record_member_payment(@member, @payment.amount, @payment.payment_source)

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
