module Admin
  class HoldsController < BaseController
    include Pagy::Backend

    def index
      holds_scope = Hold.active
      # loan_summaries_scope = LoanSummary.send(index_filter)
      #   .order(latest_loan_id: :desc)
      #   .joins(:member)
      #   .merge(Member.verified)
      #   .includes(:item, :member)
      @pagy, @holds = pagy(holds_scope, items: 100)
    end

    private
  end
end
