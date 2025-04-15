module Volunteer
  class MonthCalendar
    attr_reader :first_date
    attr_reader :last_date

    def initialize(events, today = nil)
      @events = events
      @today = today || Time.zone.now.to_date
      @first_date = @today.beginning_of_month.beginning_of_week(:sunday)
      @last_date = @today.end_of_month.end_of_week(:sunday)
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
        events = if state.nil?
          @events.select { |event|
            event.start.between?(date.beginning_of_day, date.end_of_day)
          }
        else
          []
        end
        yield Day.new(date, @today, events, state)
        date += 1.day
      end
    end
  end
end
