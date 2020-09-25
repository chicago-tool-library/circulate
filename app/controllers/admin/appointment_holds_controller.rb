module Admin
  class AppointmentHoldsController < ApplicationController
    def create
      redirect_to admin_appointment_path(appointment), flash: { error: "Please enter item ID!" } and return if params[:item_id].blank?
      add_new_appointment_hold
    end

    def destroy
      remove_appointment_hold
      redirect_to admin_appointment_path(appointment), flash: { success: "Item removed from appointment." }
    end

    private

    def remove_appointment_hold
      @remove_appointment_hold ||= appointment.appointment_holds.find_by(hold_id: params[:id]).destroy
    end

    def add_new_appointment_hold
      hold = appointment.member.holds.new(item_id: params[:item_id], member: current_member, creator: current_member.user)
      if hold.save
        appointment.appointment_holds.create!(hold: hold)
        redirect_to admin_appointment_path(appointment), flash: { success: "Item added to appointment." }
      else
        redirect_to admin_appointment_path(appointment), flash: { error: "Item not found!" }
      end
    end

    def appointment
      @appointment ||= Appointment.find(params[:appointment_id])
    end
  end
end