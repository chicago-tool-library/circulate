module Account
  class RenewalsController < BaseController
    include Lending

    def create
      @loan = Loan.find(params[:loan_id])
      authorize @loan, :renew?

      renew_loan(@loan)
      redirect_to account_home_path
    end
  end
end
