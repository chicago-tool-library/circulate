module Volunteer
  class ShiftsController < ApplicationController
    def index
      Date.beginning_of_week = :sunday

      if params[:month] && params[:year]
        @month = MonthCalendar.new(date_from_params, Time.current.to_date)
      else
        @month = MonthCalendar.new(Time.current.to_date)
      end
    end

    private

    def date_from_params
      Date.new(params[:year].to_i, params[:month].to_i)
    rescue ArgumentError
      Time.current.to_date
    end
  end
end