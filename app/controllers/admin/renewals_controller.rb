module Admin
  class RenewalsController < BaseController
    include ActionView::RecordIdentifier

    def create
      @loan = Loan.find(params[:loan_id])
      @renewal = @loan.renew!

      redirect_to admin_member_url(@loan.member_id, anchor: dom_id(@renewal))
    end

    def destroy
      @loan = Loan.find(params[:id])

      if @loan.renewal?
        @previous_loan = @loan.undo_renewal!
        redirect_to admin_member_path(@loan.member, anchor: dom_id(@previous_loan))
      else
        redirect_to admin_member_path(@loan.member, anchor: "current-loans"), error: "Renewal could not be destroyed!"
      end
    end
  end
end
