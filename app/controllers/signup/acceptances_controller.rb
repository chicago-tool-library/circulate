module Signup
  class AcceptancesController < BaseController
    before_action :load_member

    def create
      @acceptance = @member.acceptances.new(member: @member, terms: acceptance_params[:terms])
      if @acceptance.save && @current_library.allow_payments?
        redirect_to new_signup_payment_url, status: :see_other
      elsif @acceptance.save
        redirect_to signup_confirmation_url, status: :see_other
      else
        activate_step(:agreement)
        @document = Document.agreement.first!
        render "signup/documents/agreement", status: :unprocessable_entity
      end
    end

    def destroy
    end

    private

    def acceptance_params
      params.require(:agreement_acceptance).permit(:terms)
    end
  end
end
