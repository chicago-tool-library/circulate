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

  class MonthCalendar
    attr_reader :first_date
    attr_reader :last_date

    def initialize(events, today = nil)
      @events = events
      @today = today || Time.zone.now.to_date
      @first_date = @today.beginning_of_month.beginning_of_week
      @last_date = @today.end_of_month.end_of_week
    end

    def title
      @today.strftime("%B %Y")
    end

    def each_day(&block)
      date = @first_date
      loop do
        break if date > @last_date
        state = if date > @today.end_of_month
          :next
        elsif date < @today.beginning_of_month
          :previous
        end
        events = @events.select { |event|
          date.beginning_of_day <= event.start && date.end_of_day >= event.start
        }
        yield Day.new(date, @today, events, state)
        date += 1.day
      end
    end
  end
end
