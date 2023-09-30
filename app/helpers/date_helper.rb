# frozen_string_literal: true

module DateHelper
  def date_with_time_title(time)
    tag.span(time.to_s(:short_date), title: time.to_s(:short_datetime))
  end

  def time_ago_with_time_title(time)
    tag.span(time_ago_in_words(time) + " ago", title: time.to_s(:short_datetime))
  end

  def checked_out_date(datetime, day_of_week: false)
    format = "%A, %B %-d"
    datetime.strftime(format)
  end

  def appointment_date_and_time(appointment, include_time: true)
    date_string = appointment.starts_at.strftime("%A, %B %-d, %Y")
    return date_string unless include_time

    date_string + " between #{appointment.starts_at.strftime("%-I:%M%P")} and #{appointment.ends_at.strftime("%-I:%M%P")}"
  end

  def display_date(datetime, format)
    return unless datetime
    tag.time(datetime.to_s(format), datetime: datetime.utc)
  end
end
