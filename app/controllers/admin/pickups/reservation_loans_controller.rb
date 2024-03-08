module Admin
  module Pickups
    class ReservationLoansController < BaseController
      before_action :set_reservation_loan, only: :destroy

      def create
        # TODO look items up by number and not id
        @reservable_item = ReservableItem.find_by(id: reservation_loan_params[:reservable_item_id])
        if !@reservable_item
          render_form_with_error("no item found with this ID")
          return
        end

        @date_hold = @pickup.reservation.date_holds.find_by(item_pool_id: @reservable_item.item_pool_id)
        if !@date_hold
          # TODO this item isn't a part of the reservation
          # but we should handle this gracefully
          render_form_with_error("not found on this reservation")
          return
        end

        @reservation_loan = @pickup.reservation_loans.new(
          reservable_item: @reservable_item,
          date_hold: @date_hold
        )

        if @reservation_loan.save
          respond_to do |format|
            format.turbo_stream do
              render turbo_stream: turbo_stream.action(:redirect, admin_pickup_url(@pickup))
            end
          end
        else
          render_form
        end
      end

      def destroy
        @reservation_loan.destroy!

        redirect_to admin_pickup_url(@pickup)
      end

      private

      def render_form_with_error(message)
        @reservation_loan = ReservationLoan.new
        @reservation_loan.errors.add(:reservable_item_id, message)
        render_form
      end

      def render_form
        render partial: "admin/pickups/reservation_loans/form", locals: {pickup: @pickup, reservation_loan: @reservation_loan}, status: :unprocessable_entity
      end

      def set_reservation_loan
        @reservation_loan = @pickup.reservation_loans.find(params[:id])
      end

      def reservation_loan_params
        params.require(:reservation_loan).permit(:reservable_item_id)
      end
    end
  end
end
