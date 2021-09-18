module Volunteer
  class ShiftsController < BaseController
    include ShiftsHelper
    include Calendaring

    def index
      @events = Event.volunteer_shifts.upcoming
      @attendee = Attendee.new(email: session[:email], name: session[:name])
      @month_calendars = [
        Volunteer::MonthCalendar.new(@events),
        Volunteer::MonthCalendar.new(@events, 1.month.since),
        Volunteer::MonthCalendar.new(@events, 2.months.since)
      ]
    end

    def event
      @attendee = Attendee.new(email: session[:email], name: session[:name])

      @events = Event.volunteer_shifts.where(calendar_event_id: params[:event_ids])
      if @events.any?
        sync_events(params[:event_ids])
        @shift = Volunteer::Shift.new(@events)
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
