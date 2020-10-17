class AppointmentsController < ApplicationController

  before_action :authenticate_user!

  def index
    @appointments = current_user.member.appointments.upcoming.includes(:member, :holds, :loans)
  end

  def new
    @appointment = Appointment.new
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
      @appointment.time_range_string = appointment_params[:time_range_string]
      appointment_times = appointment_params[:time_range_string].split("..")
      @appointment.starts_at = DateTime.parse appointment_times[0]
      @appointment.ends_at = DateTime.parse appointment_times[1]
    end

    if @appointment.save
      redirect_to appointments_path, notice: "Appointment was successfully created."
    else
      @holds = Hold.active.where(member: current_user.member)
      @loans = current_user.member.loans.includes(:item).checked_out
      render :new, alert: @appointment.errors.full_messages
    end
  end

  private

  def appointment_params
    params.require(:appointment).permit(:comment, :time_range_string, hold_ids: [], loan_ids: [])
  end
end
