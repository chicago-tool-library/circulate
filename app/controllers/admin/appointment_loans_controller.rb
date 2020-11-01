module Admin
  class AppointmentLoansController < ApplicationController
    def create
      add_new_appointment_loan
      redirect_to admin_appointment_path(appointment), flash: create_flash_message
    end

    def destroy
      remove_appointment_loan
      redirect_to admin_appointment_path(appointment), flash: { success: "Item removed from appointment." }
    end

    private

    def remove_appointment_loan
      @remove_appointment_loan ||= appointment.appointment_loans.find_by(loan_id: params[:id]).destroy
    end

    def add_new_appointment_loan
      return if item_to_add.blank? ||
          appointment.appointment_loans.joins(:loan).exists?(loans: { item: item_to_add })

      new_appointment_loan.save
    end

    def create_flash_message
      if new_appointment_loan&.persisted?
        {success: "Item added to appointment check-ins."}
      else
        {error: "Unable to add item to appointment check-ins."}
      end
    end

    def new_appointment_loan
      return if item_to_add.blank?

      @new_appointment_loan ||= appointment.appointment_loans.new(
        loan: loan_for_item_to_add
      )
    end

    def loan_for_item_to_add
      @item_to_add_loan = appointment.member.loans.find_or_initialize_by(item: item_to_add)
    end

    def item_to_add
      Item.find_by_complete_number(params.require(:appointment_loan)[:item_id].to_s)
    end

    def appointment
      @appointment ||= Appointment.find(params[:appointment_id])
    end
  end
end