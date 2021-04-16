module Admin
  class RenewalsController < BaseController
    include ActionView::RecordIdentifier
    include Lending

    def create
      @loan = Loan.find(params[:loan_id])
      @renewal = renew_loan(@loan)

      redirect_to admin_member_url(@loan.member_id, anchor: dom_id(@renewal))
    end

    def destroy
      @loan = Loan.find(params[:id])

      if @loan.renewal?
        @previous_loan = undo_loan_renewal(@loan)
        redirect_to admin_member_path(@loan.member, anchor: dom_id(@previous_loan))
      else
        redirect_to admin_member_path(@loan.member, anchor: "current-loans"), error: "Renewal could not be destroyed!"
      end
    end
  end
end
