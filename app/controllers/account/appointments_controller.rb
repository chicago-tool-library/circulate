module Account
  class AppointmentsController < BaseController
    include AppointmentSlots

    def index
      @appointments = current_user.member.appointments.upcoming.includes(:member, :holds, :loans)
    end

    def new
      @member = current_user.member
      @appointment = Appointment.new

      load_holds_and_loans
      load_appointment_slots
    end

    def create
      @member = current_user.member
      @appointment = Appointment.new

      if update_appointment
        redirect_to account_appointments_path, success: "Your appointment was scheduled for #{helpers.appointment_date_and_time(@appointment)}."
      else
        load_holds_and_loans
        load_appointment_slots
        render :new, alert: @appointment.errors.full_messages
      end
    end

    def edit
      @member = current_user.member
      @appointment = @member.appointments.find(params[:id])

      load_holds_and_loans
      load_appointment_slots
    end

    def update
      @member = current_user.member
      @appointment = @member.appointments.find(params[:id])

      if update_appointment
        redirect_to account_appointments_path, success: "Appointment was successfully updated."
      else
        load_holds_and_loans
        load_appointment_slots
        render :edit, alert: @appointment.errors.full_messages
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

    def update_appointment
      params = {
        member: @member,
        holds: Hold.where(id: appointment_params[:hold_ids], member: @member),
        loans: Loan.where(id: appointment_params[:loan_ids], member: @member),
        comment: appointment_params[:comment],
        time_range_string: appointment_params[:time_range_string],
        member_updating: true
      }

      @appointment.update(params)
    end

    def load_holds_and_loans
      @holds = Hold.active.includes(member: {appointments: :holds}).where(member: @member)
      @loans = @member.loans.includes(:item, member: {appointments: :loans}).checked_out
    end
  end
end
