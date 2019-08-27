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
    @title = "Today's account summary"
    mail(to: @member.email, subject: @title)
  end
end
