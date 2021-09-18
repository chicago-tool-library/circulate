module Google
  class Calendar
    TOKEN_ENDPOINT = "https://www.googleapis.com/oauth2/v4/token"

    def initialize(calendar_id:)
      @calendar_id = calendar_id
    end

    def upcoming_events(start_time, end_time)
      events_response = client.get(events_endpoint, params: {
        orderBy: "startTime",
        singleEvents: true,
        timeZone: "America/Chicago",
        timeMin: start_time.rfc3339,
        timeMax: end_time.rfc3339,
        showDeleted: true
      })

      if events_response.status == 200
        events = events_response.parse.fetch("items", []).map { |event| gcal_event_to_event(event) }
        Result.success(events)
      else
        Result.failure(events_response.body)
      end
    end

    def fetch_event(event_id)
      event_url = events_endpoint + "/#{event_id}"
      event_response = client.get(event_url)
      unless event_response.status == 200
        return Result.failure(event_response.body.to_s)
      end
      Result.success(gcal_event_to_event(event_response.parse))
    end

    def fetch_events(event_ids)
      results = event_ids.map { |id| fetch_event(id) }
      if results.any? { |r| r.failure? }
        Result.failure("could not fetch events")
      else
        Result.success(results.map(&:value))
      end
    end

    def add_attendee_to_event(attendee, event_id)
      # get event by id
      event_url = events_endpoint + "/#{event_id}"
      event_response = client.get(event_url)
      unless event_response.status == 200
        return Result.failure(event_response.body.to_s)
      end

      # build new list of attendees
      event = event_response.parse
      attendees = event["attendees"] || []
      attendees << {
        email: attendee.email,
        displayName: attendee.name,
        responseStatus: "accepted"
      }

      # update event
      patch_response = client.patch(event_url, json: {
        attendees: attendees
      })
      if patch_response.status == 200
        event = gcal_event_to_event(patch_response.parse)
        Result.success(event)
      else
        Result.failure(patch_response.body.to_s)
      end
    end

    def remove_attendee_from_event(attendee, event_id)
      # get event by id
      event_url = events_endpoint + "/#{event_id}"
      event_response = client.get(event_url)
      unless event_response.status == 200
        return Result.failure(event_response.body.to_s)
      end

      # build new list of attendees
      event = event_response.parse
      attendees = event["attendees"] || []
      new_attendees = attendees.reject { |a| a["email"] == attendee.email }

      # update event
      patch_response = client.patch(event_url, json: {
        attendees: new_attendees
      })
      if patch_response.status == 200
        event = gcal_event_to_event(patch_response.parse)
        Result.success(event)
      else
        Result.failure(patch_response.body.to_s)
      end
    end

    private

    def events_endpoint
      "https://www.googleapis.com/calendar/v3/calendars/#{@calendar_id}/events"
    end

    def client
      @client ||= new_client
    end

    def new_client
      http = HTTP.use(instrumentation: {instrumenter: ActiveSupport::Notifications.instrumenter})
      token_response = http.post(TOKEN_ENDPOINT, params: {
        client_id: ENV.fetch("GOOGLE_CLIENT_ID"),
        client_secret: ENV.fetch("GOOGLE_CLIENT_SECRET"),
        grant_type: "refresh_token",
        refresh_token: ENV.fetch("GOOGLE_REFRESH_TOKEN")
      })
      token = token_response.parse["access_token"]
      http.auth("Bearer #{token}")
    end

    def gcal_event_to_event(gcal_event)
      CalendarEvent.new(
        id: gcal_event["id"],
        calendar_id: @calendar_id,
        summary: gcal_event["summary"],
        description: gcal_event["description"],
        start: Time.iso8601(gcal_event["start"]["dateTime"]),
        finish: Time.iso8601(gcal_event["end"]["dateTime"]),
        status: gcal_event["status"],
        attendees: gcal_event.fetch("attendees", []).map { |attendee|
          Attendee.new(email: attendee["email"], name: attendee["displayName"], status: attendee["responseStatus"])
        }
      )
    end
  end
end
