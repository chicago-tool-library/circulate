# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview
  def confirmation_instructions
    UserMailer.confirmation_instructions(User.first, "token")
  end

  def email_changed
    UserMailer.email_changed(User.first)
  end

  def password_change
    UserMailer.password_change(User.first)
  end

  def reset_password_instructions
    UserMailer.reset_password_instructions(User.first, "token")
  end
end
