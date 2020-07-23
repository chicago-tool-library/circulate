class Event < ApplicationRecord
  def self.update_events(gcal_events)
    gcal_events.each do |gcal_event|
      transaction(requires_new: true) do
        Event.find_or_initialize_by(
          calendar_event_id: gcal_event.id,
          calendar_id: gcal_event.calendar_id
        ).update(
          description: gcal_event.description,
          start: gcal_event.start,
          finish: gcal_event.finish,
          attendees: gcal_event.attendees,
          summary: gcal_event.summary
        )
      end
    end
  end
end
