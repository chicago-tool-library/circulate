module Admin
  module Reservations
    class ReviewsController < BaseController
      def edit
        unless @reservation.manager.can?(:approve)
          redirect_to admin_reservation_path(@reservation), error: "Can't review a reservation with status #{@reservation.manager.state}"
        end
      end

      def update
        reservation_params = {reviewer: current_user, reviewed_at: Time.current, notes: review_params[:notes]}

        event = review_params[:event].to_sym
        unless @reservation.manager.can?(event)
          redirect_to admin_reservation_path(@reservation), error: "Can't #{event} a reservation with status #{@reservation.manager.state}"
          return
        end

        @reservation.transaction do
          if @reservation.manager.trigger(event) && @reservation.update(reservation_params)
            redirect_to admin_reservation_url(@reservation), notice: "Reservation was successfully updated."
          else
            render :edit, status: :unprocessable_entity
          end
        end
      end

      private

      # Only allow a list of trusted parameters through.
      def review_params
        params.require(:reservation).permit(:notes, :event)
      end
    end
  end
end
