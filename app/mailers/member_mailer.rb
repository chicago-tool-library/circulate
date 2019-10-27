class MemberMailer < ApplicationMailer
  helper :items
  helper :members

  def welcome_message
    @member = params[:member]
    @amount = Money.new(params[:amount]) if params.key?(:amount)
    @title = "Welcome to The Chicago Tool Library"
    mail(to: @member.email, subject: @title)
  end

  def loan_summaries
    @member = params[:member]
    @summaries = params[:summaries]
    @now = params[:now] || Time.current
    @has_overdue_items = @summaries.any? { |s| s.overdue_as_of?(@now) }
    @title = if @has_overdue_items
      "You have overdue items!" 
    else
      "Today's loan summary"
    end
    mail(to: @member.email, subject: @title)
  end
end
