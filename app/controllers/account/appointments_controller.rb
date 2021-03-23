module Account
  class AppointmentsController < BaseController
    def index
      @appointments = current_user.member.appointments.upcoming.includes(:member, :holds, :loans)
    end

    def new
      @appointment = Appointment.new
      @holds = Hold.active.includes(member: {appointments: :holds}).where(member: current_user.member)
      @loans = current_user.member.loans.includes(:item, member: {appointments: :loans}).checked_out
      @url = account_appointments_path
      @method = :post
      load_appointment_slots
    end

    def create
      member = current_user.member
      @appointment = Appointment.new

      if @appointment.update(appointment_fields)
        redirect_to account_appointments_path, notice: "Appointment was successfully created."
      else
        @holds = Hold.active.where(member: member)
        @loans = member.loans.includes(:item).checked_out
        @url = account_appointments_path
        @method = :post

        load_appointment_slots
        render :new, alert: @appointment.errors.full_messages
      end
    end

    def edit
      @appointment = current_user.member.appointments.find(params[:id])
      @holds = Hold.active.includes(member: {appointments: :holds}).where(member: current_user.member)
      @loans = current_user.member.loans.includes(:item, member: {appointments: :loans}).checked_out
      @comment = @appointment.comment
      @url = account_appointment_path(@appointment)
      @method = :put
      @appointment.time_range_string = @appointment.starts_at.to_s + ".." + @appointment.ends_at.to_s
      load_appointment_slots
    end

    def update
      member = current_user.member
      @appointment = member.appointments.find(params[:id])

      if @appointment.update(appointment_fields)
        redirect_to account_appointments_path, notice: "Appointment was successfully updated."
      else
        @holds = Hold.active.where(member: member)
        @loans = member.loans.includes(:item).checked_out
        @url = account_appointment_path(@appointment)
        @method = :put
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

    def appointment_fields
      member = current_user.member

      if appointment_params[:time_range_string].present?
        time_range_string = appointment_params[:time_range_string]
        appointment_times = time_range_string.split("..")
        starts_at = DateTime.parse appointment_times[0]
        ends_at = DateTime.parse appointment_times[1]
      end

      {
        member: member,
        holds: Hold.where(id: appointment_params[:hold_ids], member: member),
        loans: Loan.where(id: appointment_params[:loan_ids], member: member),
        comment: appointment_params[:comment],
        time_range_string: time_range_string,
        starts_at: starts_at,
        ends_at: ends_at
      }
    end

    def update_appointment(appointment, url, method)
      if appointment.update(appointment_fields)
        redirect_to account_appointments_path, notice: "Appointment was successfully saved."
      else
        @holds = Hold.active.where(member: current_user.member)
        @loans = current_user.member.loans.includes(:item).checked_out
        @url = url
        @method = method
        load_appointment_slots
        render :new, alert: appointment.errors.full_messages
      end
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
