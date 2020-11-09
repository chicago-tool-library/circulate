namespace :sync do
    
  desc "Syncronizes calendars with the events database"
  task :calendars => :environment do
    sync_calendar ENV.fetch("APPOINTMENT_SLOT_CALENDAR_ID")
    # TODO also sync other calendars
    # sync_calendar ENV.fetch("VOLUNTEER_SLOT_CALENDAR_ID")
  end

end

def sync_calendar(calendar_id)
  calendar = GoogleCalendar.new(calendar_id: calendar_id)
  result = calendar.upcoming_events(Time.zone.now, 1.month.since)
  if result.success?
    Event.update_events(result.value)
  else
    raise "Could not sync events: #{result.error}"
  end
end