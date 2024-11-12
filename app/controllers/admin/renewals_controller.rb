module Admin
  class RenewalsController < BaseController
    include ActionView::RecordIdentifier
    include Lending

    def create
      @loan = Loan.find(params[:loan_id])
      @renewal = renew_loan(@loan)

      if @renewal
        flash_highlight(@renewal)
        redirect_to admin_member_url(@loan.member_id), status: :see_other
      else
        redirect_to admin_member_url(@loan.member_id), error: "That item couldn't be renewed.", status: :see_other
      end
    end

    def destroy
      @loan = Loan.find(params[:id])

      if @loan.renewal?
        @previous_loan = undo_loan_renewal(@loan)
        flash_highlight(@previous_loan)
        redirect_to admin_member_path(@loan.member), status: :see_other
      else
        redirect_to admin_member_path(@loan.member, anchor: "current-loans"), error: "Renewal could not be destroyed!", status: :see_other
      end
    end
  end
end
