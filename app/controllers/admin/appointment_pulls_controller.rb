module Admin
  class AppointmentPullsController < BaseController
    include ActionView::RecordIdentifier

    before_action :are_appointments_enabled?

    def create
      @appointment = Appointment.find(params[:appointment_id])
      @appointment.update!(pulled_at: Time.current, staff_updating: true)

      render_appointment_to_turbo_stream
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
          render turbo_stream: [
            turbo_stream.replace(
              "#{dom_id(@appointment)}-mobile",
              render_to_string(partial: "admin/appointments/appointment_mobile", locals: {appointment: @appointment})
            ),
            turbo_stream.replace(
              "#{dom_id(@appointment)}-desktop",
              render_to_string(partial: "admin/appointments/appointment", locals: {appointment: @appointment})
            ),
            turbo_stream.action("arrangeAppointment", "#{dom_id(@appointment)}-desktop")
          ]
        }
      end
    end
  end
end
