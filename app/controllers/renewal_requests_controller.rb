class RenewalRequestsController < ApplicationController
  before_action :load_member
  layout "renewals"

  def status
    @summaries = @member.loan_summaries
      .active_on(Time.current)
      .or(@member.loan_summaries.checked_out)
      .includes(item: :borrow_policy)
      .by_due_date
    @has_overdue_items = @summaries.any? { |s| s.overdue_as_of?(Time.current.beginning_of_day.tomorrow) }
  end

  def show
    @renewal_request = RenewalRequest.new(loan_source: @member.loans)
    render_show
  end

  def update
    @renewal_request = RenewalRequest.new(
      loan_source: @member.loans,
      loan_ids: renewal_params[:loan_ids].reject(&:empty?)
    )

    if @renewal_request.commit
      redirect_to status_renewal_request_url(params[:id]), success: "Renewal request submitted."
    else
      render_show
    end
  end

  private

  def render_show
    @renewable_loans = @member.loan_summaries.renewable
    @not_renewable_loans = @member.loan_summaries.renewable(false)
    render :show
  end

  def renewal_params
    params.require("renewal_request").permit(loan_ids: [])
  end

  def load_member
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
  end
end
