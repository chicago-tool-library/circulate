module Admin
  class AppointmentHoldsController < ApplicationController
    before_action :are_appointments_enabled?

    def create
      add_new_appointment_hold
      redirect_to admin_appointment_path(appointment), flash: create_flash_message, status: :see_other
    end

    def destroy
      remove_appointment_hold
      redirect_to admin_appointment_path(appointment), flash: {success: "Item removed from appointment."}, status: :see_other
    end

    private

    def remove_appointment_hold
      @remove_appointment_hold ||= appointment.appointment_holds.find_by(hold_id: params[:id]).destroy

      if params[:cancel_hold].to_s.downcase == "true"
        Hold.find(params[:id]).destroy
      end
    end

    def add_new_appointment_hold
      return if item_to_add.blank? ||
        item_to_add.allow_one_holds_per_member? &&
          appointment.appointment_holds.joins(:hold).exists?(holds: {item: item_to_add})

      new_appointment_hold.save
    end

    def create_flash_message
      if new_appointment_hold&.persisted?
        {success: "Item added to appointment check-outs."}
      else
        {error: "Unable to add item to appointment check-outs."}
      end
    end

    def new_appointment_hold
      return if item_to_add.blank?

      @new_appointment_hold ||= appointment.appointment_holds.new(
        hold: hold_for_item_to_add
      )
    end

    def hold_for_item_to_add
      @item_to_add_hold ||= if item_to_add.allow_multiple_holds_per_member?
        appointment.member.holds.new(item: item_to_add, creator: current_user)
      elsif item_to_add.available?
        appointment.member.active_holds.find_or_initialize_by(item: item_to_add, creator: current_user)
      end
    end

    def item_to_add
      Item.find_by_complete_number(params.require(:appointment_hold)[:item_id].to_s)
    end

    def appointment
      @appointment ||= Appointment.find(params[:appointment_id])
    end
  end
end
