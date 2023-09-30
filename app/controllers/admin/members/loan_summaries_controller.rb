# frozen_string_literal: true

module Admin
  module Members
    class LoanSummariesController < BaseController
      include Pagy::Backend

      def index
        @pagy, @loan_summaries = pagy(@member.loan_summaries.includes(item: :borrow_policy).order(created_at: "desc"), items: 50)
      end
    end
  end
end
