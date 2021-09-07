module Volunteer
  class Shift
    FULLY_STAFFED_COUNT = 2

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

    def staffed?
      accepted_attendees_count >= FULLY_STAFFED_COUNT
    end

    def accepted_attendees_count
      @events.map(&:accepted_attendees_count).sum
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
      @events.map(&:calendar_event_id)
    end

    def each_event(&block)
      @events.each(&block)
    end
  end
end
