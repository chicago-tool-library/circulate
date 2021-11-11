module Admin
  class AppointmentCompletionsController < BaseController
    before_action :are_appointments_enabled?

    include PortalRendering

    def create
      @appointment = Appointment.find(params[:appointment_id])
      @appointment.update!(completed_at: Time.current)
      render_to_portal("admin/appointments/appointment", table_row: true, locals: {appointment: @appointment})
    end

    def destroy
      @appointment = Appointment.find(params[:appointment_id])
      @appointment.update!(completed_at: nil)
      render_to_portal("admin/appointments/appointment", table_row: true, locals: {appointment: @appointment})
    end
  end
end
