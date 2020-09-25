module Admin
  class AppointmentHoldsController < ApplicationController
    def destroy
      remove_appointment_hold
      redirect_to admin_appointment_path(appointment), flash: { success: "Item removed from appointment." }
    end

    private

    def remove_appointment_hold
      @remove_appointment_hold ||= appointment.appointment_holds.find_by(hold_id: params[:id]).destroy
    end

    def appointment
      @appointment ||= Appointment.find(params[:appointment_id])
    end
  end
end