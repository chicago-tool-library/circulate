module Account
  class LoansController < BaseController
    include Lending

    def index
      @loans = current_member.loans.checked_out.includes(:item, :renewal_requests).order(:due_at)
    end

    def history
      @loans = current_member.loan_summaries.returned.order(ended_at: :desc)
    end

    def renew_all
      current_member.loans.checked_out.each do |loan|
        renew_loan(loan) if loan.member_renewable?
      end

      redirect_to account_loans_path, status: :see_other, success: "Renewed all loaned items"
    end
  end
end
