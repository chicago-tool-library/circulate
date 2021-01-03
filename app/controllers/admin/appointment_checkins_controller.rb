module Admin
  class AppointmentCheckinsController < BaseController
    def create
      @appointment = Appointment.find(params[:appointment_id])
      @loans = @appointment.loans.checked_out.where(id: params[:loan_ids])

      returned_loans = @appointment.member.transaction do
        @loans.map(&:return!)
      end
      returned_loans&.each do |loan|
        if (hold = loan.item.next_hold)
          hold.start!
          MemberMailer.with(member: hold.member, hold: hold).hold_available.deliver_later
        end
      end
      returned_item_count = returned_loans&.count&.to_i

      redirect_to admin_appointment_path(@appointment), flash: {
        success: "#{helpers.pluralize(returned_item_count, "Item")} checked-in."
      }
    end
  end
end
