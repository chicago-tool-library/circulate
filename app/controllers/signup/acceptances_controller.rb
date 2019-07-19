module Signup
  class AcceptancesController < BaseController
    before_action :load_member

    def create
      @acceptance = @member.acceptances.new(member: @member, terms: acceptance_params[:terms])
      if @acceptance.save
        redirect_to new_signup_payment_url
      else
        activate_step(:agreement)
        @document = Document.agreement
        render "signup/documents/show"
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
