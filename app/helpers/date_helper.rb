module DateHelper
  def date_with_time_title(time)
    tag.span(time.to_s(:short_date), title: time.to_s(:short_datetime))
  end
end
