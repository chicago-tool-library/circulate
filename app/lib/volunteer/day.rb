module Volunteer
  class Day
    def initialize(date, today, events, state = nil)
      @date = date
      @today = today
      @events = events
      @state = state
    end

    def number
      @date.day
    end

    def today?
      @today == @date
    end

    def past?
      @date < @today
    end

    def previous_month?
      @state == :previous
    end

    def next_month?
      @state == :next
    end

    def events?
      @events.any?
    end

    def each_shift(&block)
      @events.group_by { |e| [e.start, e.finish] }.each do |((start, finish), shift_events)|
        yield Shift.new(shift_events)
      end
    end
  end
end
