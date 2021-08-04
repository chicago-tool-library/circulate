module Volunteer
  class Shift
    def initialize(events)
      @events = events
    end

    def times
      @events.first.times
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
