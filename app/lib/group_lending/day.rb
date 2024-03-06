module GroupLending
  class Day
    attr_reader :date, :data
    def initialize(date, today, state, data = nil)
      @date = date
      @today = today
      @state = state
      @data = data
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
end
