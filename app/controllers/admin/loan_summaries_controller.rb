module Admin
  class LoanSummariesController < BaseController
    include Pagy::Backend

    def index
      loan_summaries_scope = LoanSummary.send(index_filter)
        .order(latest_loan_id: :desc)
        .joins(:member)
        .merge(Member.verified)
        .includes(:item, :member)
      @pagy, @loan_summaries = pagy(loan_summaries_scope, items: 50)
    end

    private

    INDEX_FILTERS = [
      CHECKED_OUT = "checked_out",
      OVERDUE = "overdue",
      RETURNED = "returned"
    ]

    def index_filter
      case params[:filter]
      when CHECKED_OUT
        CHECKED_OUT
      when OVERDUE
        OVERDUE
      when RETURNED
        RETURNED
      else
        CHECKED_OUT
      end
    end
  end
end
