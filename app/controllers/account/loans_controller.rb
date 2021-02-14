module Account
  class LoansController < BaseController
    def index
      @loans = current_member.loan_summaries.order(ended_at: :desc)
    end
  end
end
