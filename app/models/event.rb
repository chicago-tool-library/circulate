class Event < ApplicationRecord
  scope :upcoming, -> { where("start > ?", Time.current) }

  scope :appointment_slots, -> {
    upcoming.where(calendar_id: appointment_slot_calendar_id).order("start ASC")
  }

  def date
    start.to_date
  end

  def times
    hour_meridian = "%l%P"
    start.strftime(hour_meridian) + " - " + finish.strftime(hour_meridian).strip
  end

  def self.update_events(gcal_events)
    transaction(requires_new: true) do
      gcal_events.each do |gcal_event|
        if gcal_event.cancelled?
          Event.where(
            calendar_event_id: gcal_event.id,
            calendar_id: gcal_event.calendar_id
          ).delete_all
        else
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

  def self.appointment_slot_calendar_id
    ENV.fetch("APPOINTMENT_SLOT_CALENDAR_ID")
  end
end
