module Google
  # This object is only used during tests to circumvent connections to the Google Calendar API.
  class TestCalendar
    def initialize(calendar_id:)
      @calendar_id = calendar_id
    end

    def upcoming_events(start_time, end_time)
      events = Event.where(calendar_id: @calendar_id).map { |event|
        event_to_gcal_event(event)
      }
      Result.success(events)
    end

    def fetch_event(event_id)
      Result.success(fake_event)
    end

    def fetch_events(event_ids)
      events = Event.where(calendar_id: @calendar_id).where(calendar_event_id: event_ids).map { |event|
        event_to_gcal_event(event)
      }
      Result.success(events)
    end

    def add_attendee_to_event(attendee, event_id)
      event = Event.where(calendar_id: @calendar_id).where(calendar_event_id: event_id).first
      gcal_event = event_to_gcal_event(event)
      gcal_event.attendees << Attendee.new(status: "accepted", email: attendee.email, name: attendee.name)
      Result.success(gcal_event)
    end

    def remove_attendee_from_event(attendee, event_id)
      event = Event.where(calendar_id: @calendar_id).where(calendar_event_id: event_id).first
      gcal_event = event_to_gcal_event(event)
      gcal_event.attendees.reject! do |event_attendee|
        event_attendee.email == attendee.email
      end
      Result.success(gcal_event)
    end

    private

    def event_to_gcal_event(event)
      CalendarEvent.new(
        id: event.calendar_event_id,
        calendar_id: event.calendar_id,
        summary: event.summary,
        attendees: event.attendees,
        start: event.start,
        finish: event.finish,
        status: "confirmed",
        description: event.description
      )
    end
  end
end
