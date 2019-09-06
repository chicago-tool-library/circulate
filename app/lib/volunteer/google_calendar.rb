module Volunteer
  class GoogleCalendar
    TOKEN_ENDPOINT = "https://www.googleapis.com/oauth2/v4/token"
    EVENTS_ENDPOINT = "https://www.googleapis.com/calendar/v3/calendars/#{ENV.fetch("GCAL_CALENDAR_ID")}/events"

    def upcoming_events(start_time, end_time)
      http = HTTP#.use(logging: {logger: Logger.new(STDOUT)})
      token_response = http.post(TOKEN_ENDPOINT, params: {
                                                  client_id: ENV.fetch("GCAL_CLIENT_ID"),
                                                  client_secret: ENV.fetch("GCAL_CLIENT_SECRET"),
                                                  grant_type: "refresh_token",
                                                  refresh_token: ENV.fetch("GCAL_REFRESH_TOKEN"),
                                                })
      # puts token_response.inspect
      token = token_response.parse["access_token"]

      events_response = http.auth("Bearer #{token}").get(EVENTS_ENDPOINT, params: {
                                                                  orderBy: "startTime",
                                                                  singleEvents: true,
                                                                  timeZone: "America/Chicago",
                                                                  timeMin: start_time.rfc3339,
                                                                  timeMax: end_time.rfc3339,
                                                                })

      if events_response.status == 200
        events = events_response.parse.fetch("items", []).map { |event| gcal_event_to_event(event) }
        return Result.new(true, events, nil)
      else
        return Result.new(false, [], events_response.body)
      end
    end

    private

    def gcal_event_to_event(gcal_event)
      Event.new(
        id: gcal_event["id"],
        start: Time.iso8601(gcal_event["start"]["dateTime"]),
        finish: Time.iso8601(gcal_event["end"]["dateTime"]),
        attendees: gcal_event.fetch("attendees", []).map { |attendee| 
          Attendee.new(email: attendee["email"])
        },
      )
    end
  end
end