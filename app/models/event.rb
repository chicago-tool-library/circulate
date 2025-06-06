class Event < ApplicationRecord
  attribute :attendees, Attendee.to_array_type, default: -> { [] }

  scope :upcoming, -> { where("start > ?", Time.current) }

  acts_as_tenant :library

  scope :appointment_slots, ->(now = Time.current) {
    where(calendar_id: appointment_slot_calendar_id)
      .where("finish > ?", now + 15.minutes).order("start ASC")
  }
  scope :volunteer_shifts, -> {
    upcoming.where(calendar_id: volunteer_shift_calendar_id).order("start ASC")
  }

  # Returns the next Date where the library is open on or after the specified time
  # Use by Loans to set due_at
  # If no open day is found, returns the Date of the timestamp that was passed in
  def self.next_open_day(on_or_after_time = Time.current)
    start = on_or_after_time.beginning_of_day
    next_open_event = where(calendar_id: appointment_slot_calendar_id)
      .where("DATE(start) >= ?", start)
      .order("start ASC")
      .limit(1)
      .first

    if next_open_event.nil?
      Appsignal.send_error(RuntimeError.new("No open days found on Google Calendar #{appointment_slot_calendar_id} after #{start.to_date}"))
      return start.to_date
    end

    next_open_event.start.to_date
  end

  def date
    start.to_date
  end

  def times
    format = "%l:%M%P"
    "#{start.strftime(format).strip} - #{finish.strftime(format).strip}".gsub(":00", "").strip
  end

  def attended_by?(email)
    attendees.any? { |a| a.email == email && a.status == "accepted" }
  end

  def accepted_attendees_count
    attendees.count { |a| a.accepted? }
  end

  # The title of the event is a simplified summary, mostly used to
  # group similar events together for display purposes.
  def title
    summary.gsub(/\(.+\)/, "").strip
  end

  def self.update_events(gcal_events)
    transaction(requires_new: true) do
      gcal_events.each do |gcal_event|
        update_event(gcal_event)
      end
    end
  end

  def self.update_event(gcal_event)
    if gcal_event.cancelled?
      Event.where(
        calendar_event_id: gcal_event.id,
        calendar_id: gcal_event.calendar_id
      ).delete_all
    else
      event = Event.find_or_initialize_by(
        calendar_event_id: gcal_event.id,
        calendar_id: gcal_event.calendar_id
      )

      event.update!(
        description: gcal_event.description,
        start: gcal_event.start,
        finish: gcal_event.finish,
        attendees: gcal_event.attendees.map { |a| Attendee.new(email: a.email, name: a.name, status: a.status) },
        summary: gcal_event.summary
      )
    end
  end

  def self.appointment_slot_calendar_id
    ENV.fetch("APPOINTMENT_SLOT_CALENDAR_ID")
  end

  def self.volunteer_shift_calendar_id
    ENV.fetch("VOLUNTEER_SLOT_CALENDAR_ID")
  end
end
