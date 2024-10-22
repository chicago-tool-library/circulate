module Admin
  module Reservations
    class StatusesController < BaseController
      def update
        if @reservation.update(reservation_params)
          redirect_to default_reservation_tab_path(@reservation), notice: "Reservation was successfully updated."
        else
          redirect_to default_reservation_tab_path(@reservation), error: "Reservation could not updated: #{@reservation.errors.full_messages.join(", ")}"
        end
      end

      private

      # Only allow a list of trusted parameters through.
      def reservation_params
        params.require(:reservation).permit(:status)
      end
    end
  end
end
