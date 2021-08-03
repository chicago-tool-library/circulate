module ShiftsHelper
  def each_shift(events, &block)
    last_date = nil
    events.group_by { |e| e.start.to_date }.each do |date, daily_events|
      daily_events.group_by { |e| [e.start, e.finish] }.each_with_index do |((start, finish), shift_events), shift_index|
        shift_attendees_count = shift_events.inject(0) { |sum, de| de.accepted_attendees_count + sum }

        shift_events.sort_by { |e| e.summary }.each_with_index do |event, event_index|
          daily_events_size = daily_events.size if last_date != date
          shift_events_size = shift_events.size if event_index == 0
          yield date, event, daily_events_size, shift_events_size, shift_attendees_count
          last_date = date
        end
      end
    end
  end

  def calendar_day_class(day)
    return "prev-month" if day.previous_month?
    return "next-month" if day.next_month?
  end

  def calendar_date_item_class(day)
    return "date-today" if day.today?
  end
end
