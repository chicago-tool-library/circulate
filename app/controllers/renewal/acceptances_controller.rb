# frozen_string_literal: true

module Renewal
  class AcceptancesController < BaseController
    before_action :load_member

    def create
      @acceptance = @member.acceptances.new(terms: acceptance_params[:terms])
      if @acceptance.save && @current_library.allow_payments?
        redirect_to new_renewal_payment_url
      elsif @acceptance.save
        redirect_to renewal_confirmation_url
      else
        activate_step(:agreement)
        @document = Document.agreement
        render "renewal/documents/agreement"
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
