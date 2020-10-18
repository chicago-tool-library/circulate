module Account
  class RenewalsController < BaseController
    def create
      @loan = Loan.find(params[:loan_id])
      authorize @loan, :renew?

      @loan.renew!
      redirect_to account_home_path
    end
  end
end