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

  def grouped_reservation_options(current_reservation, item_pool)
    options = current_member.reservations.pending
    format = "%m/%d/%Y @ %l:%M%P"
    existing_reservation_options = options.map do |reservation|
      prefix = (reservation == current_reservation) ? "Current Reservation " : ""
      ["#{prefix}#{reservation.started_at.strftime(format)} - #{reservation.ended_at.strftime(format)} (#{reservation.name})", reservation.id]
    end
    grouped_options_for_select(
      {"Existing Reservations" => existing_reservation_options, "New Reservation" => [["Create a new reservation", "new"]]},
      current_reservation ? current_reservation.id : "new"
    )
  end

  def reservation_date_range(reservation)
    "#{reservation.started_at.to_fs(:month_day)} - #{reservation.ended_at.to_fs(:month_day)}"
  end

  def reservation_event_datetime(event)
    "#{event.start.to_fs(:month_day_year)} #{event.start.to_fs(:hour)} - #{event.finish.to_fs(:hour)}"
  end

  private

  def format_event_time(time)
    time.strftime("%l:%M%P").strip
  end
end
