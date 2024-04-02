require "test_helper"

class TwilioControllerTest < ActionDispatch::IntegrationTest
  test "updates notification status" do
    notification = create(:notification)
    post twilio_callback_url, params: {MessageSid: notification.uuid, MessageStatus: "delivered"}
    assert_equal notification.reload.status, "delivered"
  end
end
