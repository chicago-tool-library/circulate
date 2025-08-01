class UserMailer < Devise::Mailer
  default from: "Chicago Tool Library <team@chicagotoollibrary.org>"
  layout "mailer"

  after_action :store_notification

  def initialize_from_record(record)
    super # load user
    @library = @user.library
    @logo = :small
  end

  def confirmation_instructions(user, token, opts = {})
    @organization_signup = user.organizations.any?
    if @organization_signup
      opts[:subject] = @title = "Confirm your organization account"
    else
      @title = "Please confirm your email"
    end
    super
  end

  def email_changed(*args)
    @title = "Your email has changed"
    super
  end

  def password_change(*args)
    @title = "Your password has changed"
    super
  end

  def reset_password_instructions(*args)
    @title = "Reset your password"
    super
  end

  def store_notification
    Notification.create!(
      library: @library,
      action: action_name,
      address: mail.to.join(","),
      member: @user.member,
      subject: mail.subject,
      uuid: SecureRandom.uuid
    )
  end
end
