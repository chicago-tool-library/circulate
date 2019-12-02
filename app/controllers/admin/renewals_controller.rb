module Admin
  class RenewalsController < BaseController
    def create
      @loan = Loan.find(params[:loan_id])
      @loan.renew!

      redirect_to admin_member_url(@loan.member_id, anchor: "current-loans")
    end
  end
end
