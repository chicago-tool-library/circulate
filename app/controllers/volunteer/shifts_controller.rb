module Volunteer
  class ShiftsController < ApplicationController
    include ShiftsHelper

    def index
      Date.beginning_of_week = :sunday

      if params[:month] && params[:year]

        now = Date.current
        if params[:month].to_i == now.month && params[:year].to_i == now.year
          redirect_to volunteer_shifts_url
          return
        end

        events = google_calendar.upcoming_events(date_from_params, date_from_params.end_of_month).value
        @month = MonthCalendar.new(events, date_from_params, Time.current.to_date)
      else
        events = google_calendar.upcoming_events(Time.current.beginning_of_day, Time.current.end_of_month).value
        @month = MonthCalendar.new(events, Time.current.to_date)
      end
      @attendee = Attendee.new(session[:email], session[:name])
    end

    def new
      events = google_calendar.upcoming_events(date_from_params, date_from_params.end_of_month).value
      @event = events.find { |e| e.id == params[:event_id] }
    end

    def create
      if signed_in_via_google?
        @attendee = Attendee.new(session[:email], session[:name])
        result = google_calendar.add_attendee_to_event(@attendee, params[:event_id])
        if result.success?
          redirect_to volunteer_shifts_url, success: "You have signed up for the shift."
        else
          redirect_to new_volunteer_shift_url(event_id: params[:event_id]), error: result.errors
        end
      else
        # store requested event id for later reference
        session[:event_id] = params[:event_id]
        redirect_to "/auth/google_oauth2"
      end
    end

    private

    def google_calendar
      GoogleCalendar.new
    end

    def date_from_params
      Date.new(params[:year].to_i, params[:month].to_i)
    rescue ArgumentError
      Date.current
    end
  end
end