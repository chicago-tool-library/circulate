module Account
  class AppointmentsController < BaseController
    def index
      @appointments = current_user.member.appointments.upcoming.includes(:member, :holds, :loans)
    end

    def new
      @appointment = Appointment.new
      @holds = Hold.active.includes(member: {appointments: :holds}).where(member: current_user.member)
      @loans = current_user.member.loans.includes(:item, member: {appointments: :loans}).checked_out

      load_appointment_slots
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
        redirect_to account_appointments_path, notice: "Appointment was successfully created."
      else
        @holds = Hold.active.where(member: current_user.member)
        @loans = current_user.member.loans.includes(:item).checked_out
        load_appointment_slots
        render :new, alert: @appointment.errors.full_messages
      end
    end

    def destroy
      current_user.member.appointments.find(params[:id]).destroy
      redirect_to account_appointments_path, flash: {success: "Appointment cancelled."}
    end

    private

    def appointment_params
      params.require(:appointment).permit(:comment, :time_range_string, hold_ids: [], loan_ids: [])
    end

    def load_appointment_slots
      events = Event.appointment_slots.upcoming
      @appointment_slots = events.group_by { |event| event.start.to_date }.map { |date, events|
        times = events.map { |event| [helpers.format_appointment_times(event.start, event.finish), event.start..event.finish] }
        [date.strftime("%A, %B %-d, %Y"), times]
      }
    end
  end
end
