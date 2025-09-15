module Admin
  module Reservations
    class PendingReservationItemsController < BaseController
      include Sounds

      before_action :load_pending_reservation_item

      # Merge into the reservation
      def update
        result = ReservationLending.add_pending_item_to_reservation(@pending_reservation_item)
        if result.success?
          @sound_type = success_sound_path
          render_turbo_response(:update)
        else
          render_turbo_response :error
        end
      end

      # Remove from reservation
      def destroy
        if @pending_reservation_item.destroy
          @sound_type = removed_sound_path
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
