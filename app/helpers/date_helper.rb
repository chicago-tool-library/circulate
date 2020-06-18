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
end
