module Signup
  class RedemptionsController < BaseController
    before_action :load_member

    def new
      activate_step(:payment)
      @form = GiftMembershipRedemptionForm.new
    end

    def create
      @form = GiftMembershipRedemptionForm.new(form_params)
      if @form.valid?
        Membership.transaction do
          @membership = Membership.create_for_member(@member)
          @gift_membership = GiftMembership.find(@form.gift_membership_id)
          @gift_membership.redeem(@membership)
        end

        MemberMailer.with(member: @member).welcome_message.deliver_later

        reset_session
        redirect_to signup_confirmation_url, status: :see_other
      else
        activate_step(:payment)
        render :new, status: :unprocessable_content
      end
    end

    private

    def form_params
      params.require(:gift_membership_redemption_form).permit(:code)
    end
  end
end
