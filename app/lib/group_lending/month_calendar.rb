module GroupLending
  class MonthCalendar
    attr_reader :first_date
    attr_reader :last_date

    def initialize(date_to_data_map, today = nil)
      @date_to_data_map = date_to_data_map
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
        yield Day.new(date, @today, state, @date_to_data_map[date])
        date += 1.day
      end
    end
  end
end
