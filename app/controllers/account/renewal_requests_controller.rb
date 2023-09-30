# frozen_string_literal: true

module Account
  class RenewalRequestsController < BaseController
    def create
      @loan = current_member.loans.find(params[:loan_id])

      unless @loan.member_renewal_requestable?
        return head(:forbidden)
      end

      @renewal_request = RenewalRequest.new(loan: @loan)

      flash_message = if @renewal_request.save
        { success: "Renewal requested. We'll e-mail you an update." }
      else
        { error: "Something went wrong!" }
      end

      redirect_to account_loans_path, flash: flash_message
    end
  end
end
