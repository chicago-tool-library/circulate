module ReservationsHelper
  def reservation_status_options
    Reservation.statuses.map do |key, value|
      [key, key]
    end
  end
end
