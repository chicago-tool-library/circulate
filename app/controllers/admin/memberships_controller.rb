module Admin
  class MembershipsController < BaseController
    before_action :load_member

    def index
      @memberships = @member.memberships
    end

    def new
      @membership_payment = MembershipPayment.new
    end

    def create
      @membership_payment = MembershipPayment.new(payment_params)

      if @membership_payment.valid?
        membership = @member.memberships.create!(started_on: Time.current.to_date, ended_on: Time.current.to_date + 364.days)
        adjustment = @member.adjustments.create!(adjustable: membership, amount: -@membership_payment.amount)
        adjustment = @member.adjustments.create!(payment_source: @membership_payment.payment_source, amount: @membership_payment.amount)

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
      params.require(:admin_membership_payment).permit(:amount_dollars, :payment_source)
    end
  end
end