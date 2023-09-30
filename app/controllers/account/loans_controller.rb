# frozen_string_literal: true

module Account
  class LoansController < BaseController
    def index
      @loans = current_member.loans.checked_out.includes(:item, :renewal_requests).order(:due_at)
    end

    def history
      @loans = current_member.loan_summaries.returned.order(ended_at: :desc)
    end
  end
end
