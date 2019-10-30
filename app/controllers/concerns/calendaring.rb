module Calendaring
  extend ActiveSupport::Concern
  # private

  def load_upcoming_events
    Date.beginning_of_week = :sunday
    cutoff = Time.current + 60.days
    result = google_calendar.upcoming_events(Time.current.beginning_of_day, cutoff)
    if result.success?
      @events = result.value
    else
      @events = []
      flash.now[:error] = result.errors
    end
  end

  def event_signup(event_id)
    @attendee = Volunteer::Attendee.new(email: session[:email], name: session[:name])
    result = google_calendar.add_attendee_to_event(@attendee, event_id)
    if result.success?
      redirect_to volunteer_shifts_url, success: "You have signed up for the shift."
    else
      Rails.logger.error(result.errors)
      Raven.capture_message(result.errors.inspect)
      redirect_to new_volunteer_shift_url(event_id: event_id), error: result.errors
    end
  end

  def google_calendar
    Volunteer::GoogleCalendar.new
  end
end
