module Signup
  class MembersController < BaseController
    before_action :is_membership_enabled?

    def new
      if session[:member_id]
        redirect_to signup_agreement_url
        return
      end
      @member_signup_form = MemberSignupForm.new(
        reminders_via_email: true,
        reminders_via_text: true,
        receive_newsletter: true
      )
      activate_step(:profile)
    end

    def create
      @member_signup_form = MemberSignupForm.new(member_signup_form_params)

      if @member_signup_form.save
        session[:member_id] = @member_signup_form.member_id
        session[:timeout] = Time.current + 15.minutes

        redirect_to signup_agreement_url
      else
        activate_step(:profile)
        render :new
      end
    end

    private

    def member_signup_form_params
      params.require(:member_signup_form).permit(
        :full_name, :preferred_name, :email, :phone_number, :postal_code,
        :address1, :address2, :desires, :reminders_via_email, :reminders_via_text, :receive_newsletter,
        :volunteer_interest, :password, :password_confirmation, pronouns: []
      )
    end
  end
end
