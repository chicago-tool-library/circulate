module Renewal
  class AcceptancesController < BaseController
    before_action :load_member

    def create
      @acceptance = @member.acceptances.new(terms: acceptance_params[:terms])
      if @acceptance.save && @current_library.allow_payments?
        redirect_to new_renewal_payment_url, status: :see_other
      elsif @acceptance.save
        redirect_to renewal_confirmation_url, status: :see_other
      else
        activate_step(:agreement)
        @document = Document.agreement
        render "renewal/documents/agreement", status: :unprocessable_entity
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
