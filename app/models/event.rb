class Event < ApplicationRecord
  scope :upcoming, -> { where("start > ?", Time.current) }

  scope :appointment_slots, ->(now = Time.current) {
    where(calendar_id: appointment_slot_calendar_id)
      .where("finish > ?", now + 15.minutes).order("start ASC")
  }

  def date
    start.to_date
  end

  def times
    format = "%l:%M%P"
    "#{start.strftime(format).strip} - #{finish.strftime(format).strip}".gsub(/:00/, "").strip
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
