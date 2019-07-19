module Signup
  class MembersController < BaseController
    def new
      if session[:member_id]
        redirect_to signup_document_url
        return
      end
      @member = Member.new(
        reminders_via_email: true,
        reminders_via_text: true,
        receive_newsletter: true,
      )
      activate_step(:profile)
    end

    def create
      @member = Member.new(member_params)

      if @member.save
        session[:member_id] = @member.id
        session[:timeout] = Time.current + 15.minutes

        redirect_to signup_document_url
      else
        activate_step(:profile)
        render :new
      end
    end

    private

    def member_params
      params.require(:member).permit(
        :full_name, :preferred_name, :email, :pronoun, :custom_pronoun, :phone_number, :postal_code,
        :desires, :reminders_via_email, :reminders_via_text, :receive_newsletter, :volunteer_interest
      )
    end
  end
end
