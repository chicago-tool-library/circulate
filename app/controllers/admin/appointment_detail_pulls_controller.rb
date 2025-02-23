module Admin
  class AppointmentDetailPullsController < BaseController
    include ActionView::RecordIdentifier

    before_action :are_appointments_enabled?

    def create
      @appointment = Appointment.find(params[:appointment_id])
      @appointment.update!(pulled_at: Time.current, staff_updating: true)

      redirect_to admin_appointments_path, flash: {success: "Appointment items pulled."}, status: :see_other
    end

    def destroy
      @appointment = Appointment.find(params[:appointment_id])
      @appointment.update!(pulled_at: nil, staff_updating: true)

      render_appointment_to_turbo_stream
    end

    private

    def render_appointment_to_turbo_stream
      respond_to do |format|
        format.turbo_stream {
          render turbo_stream:
            turbo_stream.replace(
              "#{dom_id(@appointment)}-complete",
              render_to_string(partial: "admin/appointments/complete", locals: {appointment: @appointment})
            )
        }
      end
    end
  end
end
