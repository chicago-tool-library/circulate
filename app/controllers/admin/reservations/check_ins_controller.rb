module Admin
  module Reservations
    class CheckInsController < BaseController
      def create
        if (reservation_item_number = reservation_loan_lookup_params[:reservable_item_number])
          @reservable_item = ReservableItem.find_by(number: reservation_item_number)
          if !@reservable_item
            render_form_with_error("no item found with this number")
            return
          end
          @reservation_loan = @reservation.reservation_loans.find_by(reservable_item_id: @reservable_item.id)
        elsif (reservation_loan_id = reservation_loan_lookup_params[:reservation_loan_id])
          @reservation_loan = @reservation.reservation_loans.find_by(id: reservation_loan_id)
        end

        if !@reservation_loan
          render_form_with_error("not found on this reservation")
          return
        end

        if @reservation_loan.checked_in_at.present?
          render_form_with_error("already marked as returned")
          return
        end

        @reservation_loan.update(checked_in_at: Time.current)
        @reservation_hold = @reservation_loan.reservation_hold
      end

      def destroy
        if (reservation_loan_id = params[:id])
          @reservation_loan = @reservation.reservation_loans.find_by(id: reservation_loan_id)
        end

        if !@reservation_loan
          render_form_with_error("not found on this reservation")
          return
        end

        if @reservation_loan.checked_in_at.blank?
          render_form_with_error("not marked as returned")
          return
        end

        @reservation_loan.update(checked_in_at: nil)
        @reservation_hold = @reservation_loan.reservation_hold
        render :create
      end

      private

      def render_form_with_error(message)
        @reservation_loan_lookup_form = ReservationLoanLookupForm.new
        @reservation_loan_lookup_form.errors.add(:reservable_item_number, message)
        render_form
      end

      def render_form
        render partial: "admin/reservations/check_ins/form", locals: {reservation: @reservation, reservation_loan_lookup_form: @reservation_loan_lookup_form}, status: :unprocessable_entity
      end

      def reservation_loan_lookup_params
        params.require(:reservation_loan_lookup_form).permit(:reservable_item_number, :reservation_loan_id)
      end
    end
  end
end
