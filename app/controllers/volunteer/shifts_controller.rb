module Volunteer
  class ShiftsController < ApplicationController
    def index
      Date.beginning_of_week = :sunday

      if params[:month] && params[:year]

        now = Date.current
        if params[:month].to_i == now.month && params[:year].to_i == now.year
          redirect_to volunteer_shifts_url
          return
        end

        events = GoogleCalendar.new.upcoming_events(date_from_params, date_from_params.end_of_month).value
        @month = MonthCalendar.new(events, date_from_params, Time.current.to_date)
      else
        events = GoogleCalendar.new.upcoming_events(Time.current.beginning_of_day, Time.current.end_of_month).value
        @month = MonthCalendar.new(events, Time.current.to_date)
      end
    end

    def new
      events = GoogleCalendar.new.upcoming_events(date_from_params, date_from_params.end_of_month).value
      @event = events.find { |e| e.id == params[:event_id] }
    end

    private

    def date_from_params
      Date.new(params[:year].to_i, params[:month].to_i)
    rescue ArgumentError
      Date.current
    end
  end
end