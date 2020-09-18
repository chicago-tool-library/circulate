class GoogleCalendarEvent
  attr_reader :id, :summary, :description, :start, :finish, :attendees, :calendar_id

  def initialize(id:, summary:, start:, finish:, attendees:, calendar_id:, description: nil)
    @id = id
    @calendar_id = calendar_id
    @summary = summary
    @description = description
    @start = start
    @finish = finish
    @attendees = attendees
  end

  def accepted_attendees_count
    @attendees.count { |a| a.accepted? }
  end

  def times
    hour_meridian = "%l%P"
    @start.strftime(hour_meridian) + " - " + @finish.strftime(hour_meridian).strip
  end

  def date
    @start.to_date
  end

  def attended_by?(email)
    @attendees.any? { |a| a.email == email }
  end
end
