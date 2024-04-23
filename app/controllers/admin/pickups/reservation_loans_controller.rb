module Admin
  module Pickups
    class ReservationLoansController < BaseController
      before_action :set_reservation_loan, only: :destroy

      # There are two wolves inside this method. If :reservation_hold_id is passed, it means
      # that we're creating a ReservationLoan for an ItemPool without uniquely numbered items.
      # Otherwise, we're creating a ReservationLoan for an individual ReservableItem.
      def create
        if (reservation_hold_id = reservation_loan_params[:reservation_hold_id])
          @reservation_hold = @pickup.reservation.reservation_holds.find(reservation_hold_id)

          # TODO make quantity something provided by UI
          @reservation_loan = @pickup.reservation_loans.new(
            reservation_hold: @reservation_hold,
            quantity: @reservation_hold.quantity
          )
        else
          # TODO look items up by number and not id
          @reservable_item = ReservableItem.find_by(id: reservation_loan_params[:reservable_item_id])
          if !@reservable_item
            render_form_with_error("no item found with this ID")
            return
          end

          @reservation_hold = @pickup.reservation.reservation_holds.find_by(item_pool_id: @reservable_item.item_pool_id)
          if !@reservation_hold
            # TODO this item isn't a part of the reservation
            # but we should handle this gracefully
            render_form_with_error("not found on this reservation")
            return
          end

          @reservation_loan = @pickup.reservation_loans.new(
            reservable_item: @reservable_item,
            reservation_hold: @reservation_hold
          )
        end

        if @reservation_loan.save
          respond_to do |format|
            format.turbo_stream
          end
        else
          render_form
        end
      end

      def destroy
        @reservation_loan.destroy!

        @pickup = @reservation_loan.pickup
        @reservation_hold = @reservation_loan.reservation_hold

        respond_to do |format|
          format.turbo_stream do
            render :create
          end
        end
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
        params.require(:reservation_loan).permit(:reservable_item_id, :reservation_hold_id)
      end
    end
  end
end
