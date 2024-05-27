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
      @events.first.title
    end

    def attended_by?(email)
      @events.any? { |e| e.attended_by?(email) }
    end

    def event_ids
      @events.map(&:calendar_event_id)
    end

    def each_event(&)
      @events.sort_by(&:summary).each(&)
    end
  end
end
