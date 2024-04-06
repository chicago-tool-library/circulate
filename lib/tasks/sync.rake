namespace :sync do
  desc "Syncronizes calendars with the events database"
  task calendars: :environment do
    ActsAsTenant.with_tenant(Library.first) do
      sync_calendar Event.appointment_slot_calendar_id
      sync_calendar Event.volunteer_shift_calendar_id
    end

    wait_for_logs_to_flush
  end

  def sync_calendar(calendar_id)
    calendar = Google::Calendar.new(calendar_id: calendar_id)
    result = calendar.upcoming_events(Time.zone.now, 3.months.since)
    if result.success?
      Event.update_events(result.value)
      Rails.logger.info "Updated #{result.value.size} events"
    else
      raise "Could not sync events: #{result.error}"
    end
  end
end
