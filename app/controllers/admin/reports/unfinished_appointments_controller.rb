module Admin
  module Reports
    class UnfinishedAppointmentsController < BaseController
      def index
        @appointments = Appointment.unfinished
          .chronologically
          .includes(:member, holds: :item)
      end

      # Resolve a row straight from the worklist: mark the appointment complete
      # so it drops off the list. Reversible from the appointment page if needed.
      def complete
        appointment = Appointment.find(params[:id])
        appointment.update!(completed_at: Time.current, staff_updating: true)

        redirect_to admin_reports_unfinished_appointments_path,
          status: :see_other,
          flash: {success: "Appointment marked complete."}
      end
    end
  end
end
