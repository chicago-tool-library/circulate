module Account
  class LoansController < BaseController
    def index
      @loans = current_member.loans.order(ended_at: :desc)
    end
  end
end