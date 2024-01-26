module Admin
  module Reservations
    class ReviewsController < BaseController
      def edit
      end

      def update
        reservation_params = {reviewer: current_user, reviewed_at: Time.current}.merge(review_params)
        if @reservation.update(reservation_params)
          redirect_to admin_reservation_url(@reservation), notice: "Reservation was successfully updated."
        else
          render :edit, status: :unprocessable_entity
        end
      end

      private

      # Only allow a list of trusted parameters through.
      def review_params
        params.require(:reservation).permit(:notes, :status)
      end
    end
  end
end
