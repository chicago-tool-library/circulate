class TwilioController < ApplicationController
  # Handle callbacks from Twilio with message status
  # Per docs at https://www.twilio.com/docs/messaging/guides/track-outbound-message-status
  def callback
    notification = Notification.find_by_uuid!(params[:MessageSid])
    notification.status = params[:MessageStatus]
    notification.save!

    head :ok
  end
end
