class AppointmentsController < ApplicationController
  def new
    @holds = Hold.active.where(member: current_user.member)
    @loans = current_user.member.loans.includes(:item).checked_out
  end

  def create
    member = current_user.member
    @appointment = Appointment.new
    @appointment.comment = appointment_params[:comment]
    @appointment.member = member
    @appointment.holds << Hold.where(id: appointment_params[:hold_ids], member: member)
    @appointment.loans << Loan.where(id: appointment_params[:loan_ids], member: member)

    if appointment_params[:time_range_string].present?
      appointment_times = appointment_params[:time_range_string].split("..")
      @appointment.starts_at = DateTime.parse appointment_times[0]
      @appointment.ends_at = DateTime.parse appointment_times[1]
    end

    if @appointment.save
      redirect_to new_appointment_path, notice: "Appointment was successfully created."
    else
      render :new, alert: @appointment.errors.full_messages
    end
  end

  private

  def appointment_params
    params.require(:appointment).permit(:comment, :time_range_string, hold_ids: [], loan_ids: [])
  end
end
