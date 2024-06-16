class UserMailer < Devise::Mailer
  default from: "Chicago Tool Library <team@chicagotoollibrary.org>"
  after_action :store_notification

  def store_notification
    Notification.create!(
      action: action_name,
      address: @user.email,
      member: @user.member,
      subject: mail.subject,
      uuid: SecureRandom.uuid
    )
  end
end
