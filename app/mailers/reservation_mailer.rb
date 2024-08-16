class ReservationMailer < ApplicationMailer
  def reservation_requested
    @reservation = params[:reservation]
    @library = @reservation.library
    @to_emails = User.select { |user| user.has_role?("admin") && user.library_id === @library.id }.pluck(:email)
    @subject = "Reservation submitted for #{@reservation.started_at.to_fs(:short_date)}"
    mail(to: @reservation.submitted_by.email, subject: @subject, bcc: @to_emails)
  end

  def reviewed
    @reservation = params[:reservation]
    @library = @reservation.library
    @subject = "Your reservation for #{@reservation.started_at.to_fs(:short_date)} was #{@reservation.status}"
    mail(to: @reservation.submitted_by.email, subject: @subject)
  end
end
