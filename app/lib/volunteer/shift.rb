module Volunteer
  class Shift
    def initialize(events)
      @events = events
    end

    def times
      @events.first.times
    end

    def start
      @events.first.start
    end

    def event_count
      @events.size
    end

    def title
      if @events.any? { |e| e.summary =~ /training/i }
        "Librarian Training"
      elsif @events.any? { |e| e.summary =~ /repair/i }
        "Repair Team"
      else
        "Librarian"
      end
    end

    def attended_by?(email)
      @events.any? { |e| e.attended_by?(email) }
    end

    def event_ids
      @events.map(&:id)
    end

    def foo
      shift_attendees_count = shift_events.inject(0) { |sum, de| de.accepted_attendees_count + sum }

      shift_events.sort_by { |e| e.summary }.each_with_index do |event, event_index|
        daily_events_size = daily_events.size if last_date != date
        shift_events_size = shift_events.size if event_index == 0
        yield date, event, daily_events_size, shift_events_size, shift_attendees_count
      end
    end

    def each_event(&block)
      @events.each(&block)
    end
  end
end
