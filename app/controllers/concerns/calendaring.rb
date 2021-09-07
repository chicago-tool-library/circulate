module Calendaring
  extend ActiveSupport::Concern

  def load_upcoming_events
    # Date.beginning_of_week = :sunday
    # cutoff = Time.current + 60.days
    # result = google_calendar.upcoming_events(Time.current.beginning_of_day, cutoff)
    # if result.success?
    #   @events = result.value
    # else
    #   @events = []
    #   flash.now[:error] = result.error
    # end
    @events = Event.volunteer_shifts.upcoming
  end

  def event_signup(event_id)
    @attendee = Attendee.new(email: session[:email], name: session[:name])
    result = google_calendar.add_attendee_to_event(@attendee, event_id)
    if result.success?
      Event.update_event(result.value)
      redirect_to volunteer_shifts_url, success: "You have signed up for the shift."
    else
      Rails.logger.error(result.error)
      Raven.capture_message(result.error.inspect)
      redirect_to volunteer_event_url(event_ids: [event_id]), error: result.error
    end
  end

  def event_remove_signup(event_id)
    @attendee = Attendee.new(email: session[:email], name: session[:name])
    result = google_calendar.remove_attendee_from_event(@attendee, event_id)
    if result.success?
      Event.update_event(result.value)
      redirect_to volunteer_shifts_url, success: "Your signup was cancelled."
    else
      Rails.logger.error(result.error)
      Raven.capture_message(result.error.inspect)
      redirect_to volunteer_event_url(event_ids: [event_id]), error: result.error
    end
  end

  def google_calendar
    Google::Calendar.new(calendar_id: google_calendar_id)
  end

  def google_calendar_id
    raise "must define google_calendar_id in consuming controller"
  end
end
