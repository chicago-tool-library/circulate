# Preview all emails at http://localhost:3000/rails/mailers/reservation_mailer
class ReservationMailerPreview < ActionMailer::Preview
  def reservation_requested
    ReservationMailer.with(reservation: Reservation.last).reservation_requested
  end

  def reservation_approved
    reservation = Reservation.last

    if reservation.status != "approved"
      reservation.status = "approved"
      reservation.notes = "This reservation has been approved for a variety of reasons."
    end

    ReservationMailer.with(reservation:).reviewed
  end

  def reservation_rejected
    reservation = Reservation.last

    if reservation.status != "rejected"
      reservation.status = "rejected"
      reservation.notes = "This reservation has been rejected for a variety of reasons."
    end

    ReservationMailer.with(reservation:).reviewed
  end
end
