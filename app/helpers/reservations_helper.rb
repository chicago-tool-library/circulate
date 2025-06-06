module ReservationsHelper
  def reservation_status_options
    Reservation.statuses.map do |key, value|
      [key, key]
    end
  end

  def format_reservation_event(event)
    [event.date.to_fs(:short), format_event_times(event)].join(" ")
  end

  def format_event_times(event)
    [event.start, event.finish].map { |time| format_event_time(time) }.join(" - ")
  end

  def default_reservation_tab_path(reservation)
    manager = reservation.manager
    if manager.requested? || manager.pending?
      admin_reservation_path(reservation)
    else
      admin_reservation_loans_path(reservation)
    end
  end

  private

  def format_event_time(time)
    time.strftime("%l:%M%P").strip
  end
end
