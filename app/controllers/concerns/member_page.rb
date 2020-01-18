module MemberPage
  def load_member_page_data
    @active_loan_summaries = @member.loan_summaries.checked_out.includes(:latest_loan, item: :borrow_policy).by_due_date
    @recent_loan_summaries = @member.loan_summaries.recently_returned.includes(:adjustment, item: :borrow_policy).by_end_date.limit(10)
  end
end
