# frozen_string_literal: true

class UserMailer < Devise::Mailer
  default from: "Chicago Tool Library <team@chicagotoollibrary.org>"
  after_action :store_notification, only: [:reset_password_instructions]

  def reset_password_instructions(record, token, opts = {})
    @user = record
    @subject = "You requested a password reset"
    super
  end

  def store_notification
    Notification.create!(member: @user.member, uuid: SecureRandom.uuid, action: action_name, address: @user.email, subject: @subject)
  end
end
