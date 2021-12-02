module Account
  class LoansController < BaseController
    def index
      @loans = current_member.loan_summaries.returned.order(ended_at: :desc)
    end
  end
end
