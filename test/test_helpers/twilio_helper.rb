module TwilioHelper
  # From https://www.twilio.com/docs/iam/test-credentials#test-sms-messages
  module MagicNumbers
    SUCCESSFUL_FROM = "+15005550006"
  end

  # Via https://thoughtbot.com/blog/testing-sms-interactions
  class FakeSMS
    Message = Struct.new(:from, :to, :body, :sid, :status, keyword_init: true)

    cattr_accessor :messages
    self.messages = []

    def messages
      self
    end

    def create(from:, to:, body:, messaging_service_sid:)
      self.class.messages << Message.new(
        from: from,
        to: to,
        body: body,
        sid: fake_sid,
        status: "accepted"
      )
      self.class.messages.last
    end

    private

    # Generate a string in a similar format as a Twilio SID
    # https://www.twilio.com/docs/glossary/what-is-a-sid
    def fake_sid
      "SM#{SecureRandom.uuid.delete("-")}"
    end
  end
end
