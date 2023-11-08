module Twilio
  class ResultWrapper
    attr_accessor :result

    def initialize(result)
      @result = result
    end

    def notification_status
      Notification.twilio_status(@result&.status)
    end

    # Twilio SIDs are a two letter type followed by a UUID
    # See: https://www.twilio.com/docs/glossary/what-is-a-sid
    def notification_uuid
      @result&.sid&.slice(2..)
    end
  end
end
