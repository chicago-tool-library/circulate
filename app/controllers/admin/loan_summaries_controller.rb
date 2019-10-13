module Admin
  class LoanSummariesController < BaseController
    include Pagy::Backend

    def index
      loan_summaries_scope = LoanSummary.send(index_filter).
        order(latest_loan_id: :desc).
        joins(:member).
        merge(Member.active).
        includes(:item, :member)
      @pagy, @loan_summaries = pagy(loan_summaries_scope, items: 50)
    end

    private

    def index_filter
      allowed = %w{checked_out overdue returned}
      return params[:filter] if allowed.include? params[:filter]
      "checked_out"
    end
  end
end