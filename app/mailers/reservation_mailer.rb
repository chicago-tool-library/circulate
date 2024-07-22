class ReservationMailer < ApplicationMailer
  def reservation_requested
    @reservation = params[:reservation]
    @library = @reservation.library
    @subject = "Reservation submitted for #{@reservation.started_at.to_fs(:short_date)}"
    mail(to: @reservation.submitted_by.email, subject: @subject)
  end
end
