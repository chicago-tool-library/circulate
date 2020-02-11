class RenewalRequestsController < ApplicationController
  def show
    @member_retriever = MemberRetriever.decrypt(params[:id])
    unless @member_retriever
      render_not_found
      return
    end

    if @member_retriever.expires_at < Time.current
      render :expired, status: :gone
      return
    end

    @member = Member.find(@member_retriever.member_id)
    @loan_summaries = @member.loan_summaries.checked_out.includes(:latest_loan).by_due_date

    divided = @loan_summaries.group_by { |ls| ls.latest_loan.renewable? }
    @renewable_loans = divided.fetch(true, {})
    @not_renewable_loans = divided.fetch(false, {})
  end
end
