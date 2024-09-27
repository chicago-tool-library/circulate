module Admin
  module Reservations
    class PendingReservationItemsController < BaseController
      before_action :load_pending_reservation_item

      # Merge into the reservation
      def update
        result = ReservationLending.add_pending_item_to_reservation(@pending_reservation_item)
        if result.success?
          render_turbo_response(
            turbo_stream: turbo_stream.action(:redirect,
              admin_reservation_pickup_path(@pending_reservation_item.reservation))
          )
        else
          render_turbo_response :error
        end
      end

      # Remove from reservation
      def destroy
        if @pending_reservation_item.destroy
          render_turbo_response :destroy
        end
      end

      private

      def load_pending_reservation_item
        @pending_reservation_item = @reservation.pending_reservation_items.find(params[:id])
      end
    end
  end
end
