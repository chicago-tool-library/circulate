module Admin
  class RenewalsController < BaseController
    def create
      @loan = Loan.find(params[:loan_id])
      @loan.renew!

      redirect_to admin_member_url(@loan.member_id, anchor: "current-loans")
    end

    def destroy
      @loan = Loan.find(params[:id])

      if @loan.renewal?
        @loan.undo_renewal!
        redirect_to admin_member_path(@loan.member, anchor: "current-loans")
      else
        redirect_to admin_member_path(@loan.member, anchor: "current-loans"), error: "Renewal could not be destroyed!"
      end
    end
  end
end
