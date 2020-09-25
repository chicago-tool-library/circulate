module Admin
  class AppointmentLoansController < ApplicationController
    def destroy
      remove_appointment_loan
      redirect_to admin_appointment_path(appointment), flash: { success: "Item removed from appointment." }
    end

    private

    def remove_appointment_loan
      @remove_appointment_loan ||= appointment.appointment_loans.find_by(loan_id: params[:id]).destroy
    end

    def appointment
      @appointment ||= Appointment.find(params[:appointment_id])
    end
  end
end