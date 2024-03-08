module Account
  class RenewalsController < BaseController
    include Lending

    def create
      @loan = Loan.find(params[:loan_id])
      authorize @loan, :renew?

      renew_loan(@loan)
      redirect_to account_loans_path, success: "#{@loan.item.name} was renewed.", status: :see_other
    end
  end
end
