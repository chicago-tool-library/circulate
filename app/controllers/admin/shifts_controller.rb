module Admin
  class ShiftsController < BaseController
    include Calendaring

    def index
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
  end
end