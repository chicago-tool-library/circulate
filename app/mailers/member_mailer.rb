class MemberMailer < ApplicationMailer
  include DateHelper

  helper :items
  helper :members
  helper :date
  helper :holds
  helper :admin

  before_action :generate_uuid
  after_action :set_uuid_header
  after_action :store_notification

  def welcome_message
    @member = params[:member]
    @library = @member.library
    @amount = Money.new(params[:amount]) if params.key?(:amount)
    @subject = "Welcome to The #{@library.name}"
    mail(to: @member.email, subject: @subject)
  end

  def renewal_message
    @member = params[:member]
    @amount = Money.new(params[:amount]) if params.key?(:amount)
    @library = @member.library
    @subject = "Your membership to The Chicago Tool Library has been renewed"
    mail(to: @member.email, subject: @subject)
  end

  def membership_reminder
    @member = params[:member]
    @library = @member.library
    @subject = "Don't forget to to activate your membership!"
    mail(to: @member.email, subject: @subject)
  end

  def loan_summaries
    @subject = "Today's loan summary"
    summary_mail
  end

  def overdue_notice
    @subject = "You have overdue items!"
    @warning = "Please return all overdue items as soon as possible so other members can check them out."
    summary_mail(template_name: "overdue_notice")
  end

  def return_reminder
    @subject = "Your items are due soon"
    summary_mail
  end

  def hold_available
    @member = params[:member]
    @hold = params[:hold]
    @subject = "One of your holds is available"
    @library = @member.library
    mail(to: @member.email, subject: "#{@subject} (#{@hold.item.name})")
  end

  def renewal_request_updated
    @renewal_request = params[:renewal_request]
    @item = @renewal_request.loan.item
    @member = @renewal_request.loan.member
    @library = @member.library
    message = @renewal_request.approved? ? "Your item was renewed" : "Your item couldn't be renewed"
    @subject = "#{message} (#{@item.name})"

    mail(to: @member.email, subject: @subject)
  end

  def membership_renewal_reminder
    @member = params[:member]
    @amount = params[:amount] || Money.new(0)
    @library = @member.library
    @subject = "Time to renew your Chicago Tool Library membership!"
    mail(to: @member.email, subject: @subject)
  end

  def staff_daily_renewal_requests
    @member = params[:member]
    @renewal_requests = params[:renewal_requests]
    @library = @member.library
    @now = params[:now] || Time.current
    @subject = "Open renewal requests as of #{@now.strftime("%m/%d/%Y")}"
    mail(to: @member.email, subject: @subject)
  end

  def appointment_confirmation
    @member = params[:member]
    @library = @member.library
    @appointment = params[:appointment]
    @subject = "New appointment scheduled for #{appointment_date_and_time(@appointment, include_time: false)}"
    mail(to: @member.email, subject: @subject)
  end

  def appointment_updated
    @member = params[:member]
    @library = @member.library
    @appointment = params[:appointment]
    @subject = "An appointment was updated for #{appointment_date_and_time(@appointment, include_time: false)}"
    mail(to: @member.email, subject: @subject)
  end

  private

  def summary_mail(template_name: "summary")
    @member = params[:member]
    @library = @member.library
    @summaries = params[:summaries]
    @now = params[:now] || Time.current

    mail(to: @member.email, subject: @subject, template_name: template_name)
  end

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
    Notification.create!(member: @member, uuid: @uuid, action: action_name, address: @member.email, subject: @subject, library: @library)
  end
end
