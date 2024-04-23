# Preview all emails at http://localhost:3000/rails/mailers/reservation_mailer
class ReservationMailerPreview < ActionMailer::Preview
  def reservation_requested
    ReservationMailer.with(reservation: Reservation.last).reservation_requested
  end
end
