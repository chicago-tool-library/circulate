module Admin
  module Reservations
    class BaseController < Admin::BaseController
      before_action :set_reservation

      private

      def set_reservation
        @reservation = Reservation.find(params[:reservation_id])
      end
    end
  end
end
