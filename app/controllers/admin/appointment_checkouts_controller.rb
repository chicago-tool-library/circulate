module Admin
  class AppointmentCheckoutsController < BaseController
    include Lending

    before_action :are_appointments_enabled?

    def create
      create_loans_for_holds
      redirect_to admin_appointment_path(appointment), flash: {success: "#{pluralize(checked_out_item_count, "Item")} checked-out."}
    end

    private

    attr_accessor :new_loans

    delegate :pluralize, to: "ActionController::Base.helpers", private: true
    delegate :member, to: :appointment

    def checked_out_item_count
      new_loans&.count&.to_i
    end

    def holds
      @holds ||= appointment.holds.active.where(id: params[:hold_ids])
    end

    def appointment
      @appointment ||= Appointment.find(params[:appointment_id])
    end

    def create_loans_for_holds
      self.new_loans = member.transaction do
        holds.map do |hold|
          create_loan_from_hold(hold)
        end
      end
    end
  end
end
