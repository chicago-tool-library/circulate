module Volunteer
  class Day
    attr_reader :events

    def initialize(date, today, events, state=nil)
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
  end

  class MonthCalendar
    attr_reader :first_date
    attr_reader :last_date

    def initialize(events, day, today = nil)
      @events = events
      @first_date = day.beginning_of_month.beginning_of_week
      @last_date = day.end_of_month.end_of_week
      @day = day
      @today = today || day
    end

    def title
      @day.strftime("%B %Y")
    end

    def each_day(&block)
      date = @first_date
      loop do
        break if date > @last_date
        state = if date > @day.end_of_month
          :next
        elsif date < @day.beginning_of_month
          :previous
        end
        events = @events.select { |event|
          date.beginning_of_day <= event.start && date.end_of_day >= event.start
        }
        yield Day.new(date, @today, events, state)
        date = date + 1.day
      end
    end
  end
end