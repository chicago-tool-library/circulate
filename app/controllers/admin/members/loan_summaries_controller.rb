module Admin
  module Members
    class LoanSummariesController < BaseController
      def index
        @loan_summaries = @member.loan_summaries.includes(item: :borrow_policy).order(created_at: "desc").all
      end
    end
  end
end
