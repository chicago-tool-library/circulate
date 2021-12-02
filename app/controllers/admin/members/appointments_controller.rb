module Admin
  module Members
    class AppointmentsController < BaseController
      include AppointmentSlots

      before_action :are_appointments_enabled?

      def index
        @appointments = @member.appointments.today_or_later.chronologically
        load_appointment_slots
      end

      def create
        @appointment = Appointment.new

        if update_appointment
          redirect_to admin_appointment_path(@appointment), flash: {success: "Appointment created"}
        else
          flash[:alert] = @appointment.errors.full_messages
          redirect_to admin_member_appointments_path(@member)
        end
      end

      private

      def appointment_params
        params.require(:appointment).permit(:time_range_string)
      end

      def update_appointment
        @appointment.update(member: @member, time_range_string: appointment_params[:time_range_string], staff_updating: true)
      end
    end
  end
end
