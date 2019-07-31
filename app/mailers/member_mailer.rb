class MemberMailer < ApplicationMailer
  def welcome_message
    @member = params[:member]
    @amount = Money.new(params[:amount]) if params.key?(:amount)
    @title = "Welcome to The Chicago Tool Library"
    mail(to: @member.email, subject: @title)
  end
end
