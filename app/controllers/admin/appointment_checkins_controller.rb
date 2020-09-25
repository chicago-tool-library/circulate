module Admin
  class AppointmentCheckinsController < BaseController
    def create
      return_loaned_items
      redirect_to admin_appointment_path(appointment), flash: { success: "#{pluralize(returned_item_count, "Item")} checked-in." }
    end

    private

    attr_accessor :returned_loans

    delegate :pluralize, to: "ActionController::Base.helpers", private: true
    delegate :member, to: :appointment

    def returned_item_count
      returned_loans&.count&.to_i
    end
    
    def loans
      @loans ||= appointment.loans.checked_out.where(id: params[:loan_ids])
    end

    def appointment
      @appointment ||= Appointment.find(params[:appointment_id])
    end

    def return_loaned_items
      self.returned_loans = member.transaction do
        loans.map(&:return!)
      end
    end
  end
end
