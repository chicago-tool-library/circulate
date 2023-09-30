# frozen_string_literal: true

module AppointmentSlots
  private
    def load_appointment_slots
      events = Event.appointment_slots
      @appointment_slots = events.group_by { |event| event.start.to_date }.map { |date, events|
        times = events.map { |event| [helpers.format_appointment_times(event.start, event.finish), event.start..event.finish] }
        [date.strftime("%A, %B %-d, %Y"), times]
      }
    end
end
