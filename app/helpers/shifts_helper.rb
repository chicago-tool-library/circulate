module ShiftsHelper
  def render_day(day)
    day_classes = ["calendar-date"]
    day_classes << "prev-month" if day.previous_month?
    day_classes << "next-month" if day.next_month?

    button_classes = ["date-item"]
    button_classes << "date-today" if day.today?

    tag.div(class: day_classes) do
      tag.button(day.number, class: button_classes) +
      tag.div(class: "calendar-events") do
        day.events.map do |event|
          event_classes = ["calendar-event", "text-light", "tooltip"]
          if event.reserved_slots < 2
            event_classes << "bg-warning"
          else
            event_classes << "bg-primary"
          end
          title = "#{event.available_slots}/#{pluralize(event.slots, "shift")} available"
          tag.a(event.times, class:event_classes, href:"#calendars", data: {tooltip: event.times})+
          tag.a(title, class: "calendar-event")
        end.join.html_safe
      end
    end
  end

  def path_to_next_month
    next_date = @month.last_date + 1.day
    volunteer_shifts_path(month: next_date.month, year: next_date.year)
  end

  def path_to_previous_month
    next_date = @month.first_date - 1.day
    volunteer_shifts_path(month: next_date.month, year: next_date.year)
  end
end