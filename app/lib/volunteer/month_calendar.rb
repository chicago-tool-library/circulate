module Volunteer

  class Day
    def initialize(date, today, state=nil)
      @date = date
      @today = today
      @state = state
    end
    def events
      [Event.new(@date.to_s)]
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

    def initialize(day, today = nil)
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
        yield Day.new(date, @today, state)
        date = date + 1.day
      end
    end
  end
end