module Admin
  class DashboardController < BaseController
    def index
      @appointment_calendar = Volunteer::GoogleCalendar.new(
        calendar_id: ENV.fetch("APPOINTMENT_GOOGLE_CALENDAR_ID")
      )
      @events = @appointment_calendar.upcoming_events(4.hours.ago, 1.day.since)
    end
  end
end
