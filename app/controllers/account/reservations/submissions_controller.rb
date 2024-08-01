module Account
  module Reservations
    class SubmissionsController < BaseController
      before_action :set_reservation
      before_action :check_reservation_status

      def show
      end

      def update
        # TODO add other validation here
        @reservation.manager.request
        if @reservation.save
          ReservationMailer.with(reservation: @reservation).reservation_requested.deliver_later
          redirect_to account_reservation_url(@reservation), success: "The reservation was submitted."
        else
          redirect_to account_reservation_url(@reservation), error: "This reservation couldn't be submitted."
        end
      end

      private

      def check_reservation_status
        unless @reservation.manager.can?(:request)
          redirect_to account_reservation_url(@reservation), error: "This reservation can't be submitted."
        end
      end
    end
  end
end
