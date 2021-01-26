module Renewal
  class MembersController < BaseController
    before_action :load_member

    def edit
      activate_step(:profile)
    end

    def update
      if @member.update(member_params)
        redirect_to renewal_agreement_url
      else
        activate_step(:profile)
        render :edit
      end
    end

    private

    def member_params
      params.require(:member).permit(
        :full_name, :preferred_name, :email, :pronoun, :custom_pronoun, :phone_number, :postal_code,
        :address1, :address2, :desires, :reminders_via_email, :reminders_via_text, :receive_newsletter,
        :volunteer_interest, :password, :password_confirmation, pronouns: []
      )
    end
  end
end
