require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  setup do
    ActionMailer::Base.deliveries.clear
  end

  test "includes HTML and text parts for password reset instructions" do
    user = create(:user)

    user.send_reset_password_instructions

    mail = ActionMailer::Base.deliveries.last

    expected_link = Rails.application.routes.url_helpers.edit_user_password_url(
      host: Rails.configuration.action_mailer.default_url_options[:host]
    )

    assert mail.multipart?, "mail should be multipart"
    assert_includes mail.html_part.body.to_s, expected_link, "mail should include reset link in html part"
    assert_includes mail.text_part.body.to_s, expected_link, "mail should include reset link in text part"
  end

  test "stores a notification whenever it sends an email" do
    user = create(:user)

    assert_equal Notification.count, 0

    user.send_reset_password_instructions

    assert_equal Notification.count, 1

    user.send_email_changed_notification

    assert_equal Notification.count, 2

    subjects = ActionMailer::Base.deliveries.map(&:subject)
    assert_includes subjects, "Reset password instructions"
    assert_includes subjects, "Email Changed"

    actions = Notification.pluck(:action)
    assert_includes actions, "reset_password_instructions"
    assert_includes actions, "email_changed"

    assert_equal [user.email, user.email], Notification.pluck(:address)
  end
end
