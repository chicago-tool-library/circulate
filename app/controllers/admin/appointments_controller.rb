module Admin
  class AppointmentsController < BaseController
    def index
      @appointments = Appointment.where(starts_at: current_day.beginning_of_day..current_day.end_of_day)
    end

    def show; end

    def destroy
      current_appointment.destroy
      redirect_to admin_appointments_path, flash: { success: "Appointment cancelled." }
    end

    private

    helper_method def current_day
      @current_day = Date.parse(params[:day] ||= Date.today.to_s)
    end

    helper_method def pervious_day
      current_day - 1.day
    end

    helper_method def next_day
      current_day + 1.day
    end

    helper_method def current_appointment
      Appointment.find(params[:id])
    end

    helper_method def appointment_pickup_items
      current_appointment.holds
    end

    helper_method def appointment_return_items
      current_appointment.loans
    end

    helper_method def checkout_items_quantity_for_appointment
      appointment_pickup_items.length
    end

    helper_method def checkin_items_quantity_for_appointment
      appointment_return_items.length
    end
  end
end
