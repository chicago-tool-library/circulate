module Admin
  module Reservations
    class PendingReservationItemsController < BaseController
      def destroy
        @pending_reservation_item = @reservation.pending_reservation_items.find(params[:id])
        if @pending_reservation_item.destroy
          render_turbo_response :destroy
        end
      end
    end
  end
end
