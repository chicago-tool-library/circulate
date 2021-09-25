module Account
  class AppointmentsController < BaseController
    include AppointmentSlots

    before_action :load_appointment_for_editing, only: [:edit, :update, :destroy]

    def index
      @appointments = current_user.member.appointments.today_or_later.includes(:member, :holds, :loans)
    end

    def new
      @member = current_user.member
      @appointment = @member.appointments.new

      load_holds_and_loans
      load_appointment_slots
    end

    def create
      @member = current_user.member
      @appointment = @member.appointments.new

      if @appointment.update(appointment_params)
        message = if merge_simultaneous_appointments
          "Your existing appointment scheduled for #{helpers.appointment_date_and_time(@appointment)} has been updated."
        else
          "Your appointment was scheduled for #{helpers.appointment_date_and_time(@appointment)}."
        end
        MemberMailer.with(member: @member, appointment: @appointment).appointment_confirmation.deliver_later
        redirect_to account_appointments_path, success: message
      else
        load_holds_and_loans
        load_appointment_slots
        render :new, alert: @appointment.errors.full_messages
      end
    end

    def edit
      @member = current_user.member

      load_holds_and_loans
      load_appointment_slots
    end

    def update
      @member = current_user.member

      if @appointment.update(appointment_params)
        message = if merge_simultaneous_appointments
          "Your existing appointment scheduled for #{helpers.appointment_date_and_time(@appointment)} has been updated."
        else
          "Your appointment scheduled for #{helpers.appointment_date_and_time(@appointment)} was updated."
        end
        redirect_to account_appointments_path, success: message
      else
        load_holds_and_loans
        load_appointment_slots
        render :edit, alert: @appointment.errors.full_messages
      end
    end

    def destroy
      @appointment.destroy
      redirect_to account_appointments_path, flash: {success: "Appointment cancelled."}
    end

    private

    def appointment_params
      form_params = params.require(:appointment).permit(:comment, :time_range_string, hold_ids: [], loan_ids: [])

      {
        holds: @member.holds.where(id: form_params[:hold_ids]),
        loans: @member.loans.where(id: form_params[:loan_ids]),
        comment: form_params[:comment],
        time_range_string: form_params[:time_range_string],
        member_updating: true
      }
    end

    def load_holds_and_loans
      @holds = Hold.active.includes(member: {appointments: :holds}).where(member: @member)
      @loans = @member.loans.includes(:item, member: {appointments: :loans}).checked_out
    end

    def merge_simultaneous_appointments
      simultaneous_appointment = @member.appointments.simultaneous(@appointment).first
      if simultaneous_appointment
        simultaneous_appointment.merge!(@appointment)
        true
      end
    end

    def load_appointment_for_editing
      @appointment = current_member.appointments.find(params[:id])
      redirect_to account_appointments_path, alert: "Completed appointments can't be changed" if @appointment.completed?
    end
  end
end
