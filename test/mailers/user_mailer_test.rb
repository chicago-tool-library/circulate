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
end
