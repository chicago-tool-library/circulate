module Signup
  class RedemptionsController < BaseController
    before_action :load_member

    def new
      activate_step(:payment)
      @redemption = Redemption.new
    end

    def create
      @redemption = Redemption.new(redemption_params)
      if @redemption.valid?
        Membership.transaction do
          @membership = Membership.create_for_member(@member)
          @gift_membership = GiftMembership.find(@redemption.gift_membership_id)
          @gift_membership.redeem(@membership)
        end

        MemberMailer.with(member: @member).welcome_message.deliver_later
        
        reset_session
        redirect_to signup_confirmation_url
      else
        render :new
      end
    end

    private

    def redemption_params
      params.require(:signup_redemption).permit(:code)
    end
  end
end
