module Volunteer
  class ShiftsController < BaseController
    include ShiftsHelper
    include Calendaring

    def list
      load_upcoming_events
      @attendee = Attendee.new(email: session[:email], name: session[:name])
    end

    def index
      load_upcoming_events
      @attendee = Attendee.new(email: session[:email], name: session[:name])
      @month_calendar = Volunteer::MonthCalendar.new(@events)
    end

    def event
      @attendee = Attendee.new(email: session[:email], name: session[:name])
      result = google_calendar.fetch_events(params[:event_ids])
      if result.success?
        @shift = Volunteer::Shift.new(result.value)
      else
        redirect_to volunteer_shifts_url, error: "That event was not found"
      end
    end

    private

    def google_calendar_id
      ::Event.volunteer_shift_calendar_id
    end
  end
end
