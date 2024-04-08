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

  def text(to:, body:, send_at: nil)
    Rails.logger.debug("Sending SMS to: #{to}, body: #{body}")
    schedule_args = {}
    if send_at.present?
      schedule_args = {send_at: send_at, schedule_type: "fixed"}
    end
    client.messages.create(
      messaging_service_sid:,
      from:,
      to:,
      body:,
      **schedule_args
    )
  end

  REASONABLE_HOURS = (9...20)
  # Sends text immediately if between 9am-8pm local time, otherwise schedules
  # for tomorrow 9am.
  def text_at_reasonable_hour(to:, body:, now: Time.current)
    send_at = nil
    unless REASONABLE_HOURS.include?(now.hour)
      send_at = now.tomorrow.change(hour: REASONABLE_HOURS.first, min: 0, sec: 0)
    end
    text(to:, body:, send_at:)
  end
end
