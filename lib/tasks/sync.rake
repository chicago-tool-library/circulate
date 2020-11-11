namespace :sync do
  desc "Syncronizes calendars with the events database"
  task :calendars => :environment do
    sync_calendar Event.appointment_slot_calendar_id
    # TODO also sync other calendars
    # sync_calendar ENV.fetch("VOLUNTEER_SLOT_CALENDAR_ID")
  end

  def sync_calendar(calendar_id)
    calendar = GoogleCalendar.new(calendar_id: calendar_id)
    result = calendar.upcoming_events(Time.zone.now, 1.month.since)
    if result.success?
      Event.update_events(result.value)
      Rails.logger.info "Updated #{result.value.size} events"
    else
      raise "Could not sync events: #{result.error}"
    end
  end
end