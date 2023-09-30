# frozen_string_literal: true

module Admin
  class AppointmentCheckinsController < BaseController
    before_action :are_appointments_enabled?

    include Lending

    def create
      @appointment = Appointment.find(params[:appointment_id])
      @loans = @appointment.loans.checked_out.where(id: params[:loan_ids])

      returned_loans = @appointment.member.transaction do
        @loans.each do |loan|
          return_loan(loan)
        end
      end
      returned_item_count = returned_loans&.count&.to_i

      redirect_to admin_appointment_path(@appointment), flash: {
        success: "#{helpers.pluralize(returned_item_count, "Item")} checked-in."
      }
    end
  end
end
