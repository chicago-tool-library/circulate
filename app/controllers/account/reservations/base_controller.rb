module Account
  module Reservations
    class BaseController < Account::BaseController
      before_action :set_reservation

      private

      def set_reservation
        @reservation = Reservation.find(params[:reservation_id])
      end
    end
  end
end
