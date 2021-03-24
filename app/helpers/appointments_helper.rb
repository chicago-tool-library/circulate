module AppointmentsHelper
  def format_appointment_times(start, stop)
    date_format = "%l:%M%P"
    "#{start.strftime(date_format).strip} - #{stop.strftime(date_format).strip}"
  end

  def appointment_time(appointment)
    format_appointment_times(appointment.starts_at, appointment.ends_at)
  end
end
