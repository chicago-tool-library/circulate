class BaseTexter
  # Allow messages to use url_helpers
  include Rails.application.routes.url_helpers

  # Have url helpers use the same url options as ActionMailer
  def default_url_options
    Rails.configuration.action_mailer.default_url_options
  end

  # For overriding in tests
  cattr_accessor :from, :client

  def from
    BaseTexter.from || ENV.fetch("TWILIO_PHONE_NUMBER", nil)
  end

  # Twilio recommends using a Messaging Service instead of a phone number, so
  # this is what we set in connected environments. Phone number is still
  # included above so we can use test credentials.
  def messaging_service_sid
    ENV.fetch("TWILIO_MESSAGING_SERVICE_SID", nil)
  end

  def client
    @client ||= BaseTexter.client || Twilio::REST::Client.new
  end

  def text(to:, body:)
    Rails.logger.debug("Sending SMS to: #{to}, body: #{body}")
    client.messages.create(from:, to:, body:, messaging_service_sid:)
  end
end
