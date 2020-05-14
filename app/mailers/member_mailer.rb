class MemberMailer < ApplicationMailer
  helper :items
  helper :members
  helper :date

  before_action :generate_uuid
  after_action :set_uuid_header
  after_action :store_notification

  def welcome_message
    @member = params[:member]
    @amount = Money.new(params[:amount]) if params.key?(:amount)
    @subject = "Welcome to The Chicago Tool Library"
    mail(to: @member.email, subject: @subject)
  end

  def membership_reminder
    @member = params[:member]
    @subject = "Don't forget to to activate your membership!"
    mail(to: @member.email, subject: @subject)
  end

  def loan_summaries
    @member = params[:member]
    @summaries = params[:summaries]
    @now = params[:now] || Time.current
    @has_overdue_items = @summaries.any? { |s| s.overdue_as_of?(@now.beginning_of_day.tomorrow) }
    @subject = if @has_overdue_items
      "You have overdue items!"
    else
      "Today's loan summary"
    end
    mail(to: @member.email, subject: @subject)
  end

  private

  def generate_uuid
    @uuid = SecureRandom.uuid
  end

  def set_uuid_header
    headers["X-SMTPAPI"] = {
      unique_args: {
        uuid: @uuid
      }
    }.to_json
  end

  def store_notification
    Notification.create!(member: @member, uuid: @uuid, action: action_name, address: @member.email, subject: @subject)
  end
end
