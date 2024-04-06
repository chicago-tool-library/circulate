require "googleauth"

module Google
  class Calendar
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
        events = events_response.parse.fetch("items", []).map { |event| gcal_event_to_event(event) }.compact
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

      scope = "https://www.googleapis.com/auth/calendar"

      # Load service account credentials from the path set in GOOGLE_APPLICATION_CREDENTIALS
      auth = if ENV.key?("GOOGLE_APPLICATION_CREDENTIALS")
        Rails.logger.info "using ADC credentials"
        Google::Auth::ServiceAccountCredentials.from_env(scope: scope)
      else
        # Use GOOGLE_CLIENT_ID, GOOGLE_CLIENT_SECRET, and GOOGLE_REFRESH_TOKEN.
        Rails.logger.info "using user refresh credentials"
        Google::Auth::UserRefreshCredentials.from_env(scope: scope)
      end

      token_data = auth.fetch_access_token!
      token = token_data["access_token"]
      http.auth("Bearer #{token}")
    end

    def parse_gcal_time(time)
      zone_name = time["timeZone"]
      datetime = time["dateTime"]
      ActiveSupport::TimeZone[zone_name].iso8601(datetime)
    end

    def gcal_event_to_event(gcal_event)
      # skip all day events
      unless gcal_event["start"]["dateTime"] && gcal_event["end"]["dateTime"]
        Rails.logger.info "skipping all-day event #{gcal_event["id"]} in calendar #{@calendar_id}"
        return nil
      end
      CalendarEvent.new(
        id: gcal_event["id"],
        calendar_id: @calendar_id,
        summary: gcal_event["summary"],
        description: gcal_event["description"],
        start: parse_gcal_time(gcal_event["start"]),
        finish: parse_gcal_time(gcal_event["end"]),
        status: gcal_event["status"],
        attendees: gcal_event.fetch("attendees", []).map { |attendee|
          Attendee.new(email: attendee["email"], name: attendee["displayName"], status: attendee["responseStatus"])
        }
      )
    end
  end
end
