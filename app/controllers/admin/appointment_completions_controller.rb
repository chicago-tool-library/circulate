module Admin
  class AppointmentCompletionsController < BaseController
    include ActionView::RecordIdentifier

    before_action :are_appointments_enabled?

    def create
      @appointment = Appointment.find(params[:appointment_id])
      @appointment.update!(completed_at: Time.current, staff_updating: true)

      render_appointment_to_turbo_stream
    end

    def destroy
      @appointment = Appointment.find(params[:appointment_id])
      @appointment.update!(completed_at: nil, staff_updating: true)

      render_appointment_to_turbo_stream
    end

    private

    def render_appointment_to_turbo_stream
      partial = FeatureFlags.new_appointments_page_enabled?(params[:new]) ? "appointment" : "appointment_orig"
      respond_to do |format|
        format.turbo_stream {
          render turbo_stream:
            turbo_stream.replace(
              dom_id(@appointment),
              render_to_string(partial: "admin/appointments/#{partial}", locals: {appointment: @appointment})
            )
        }
      end
    end
  end
end
