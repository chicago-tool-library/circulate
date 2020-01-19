module Admin
  class MemberLoanSummariesController < BaseController
    def index
      @member = Member.find(params[:member_id])
      @loan_summaries = @member.loan_summaries.includes(item: :borrow_policy).order(created_at: "desc").all
    end
  end
end
