module Admin
  module Reservations
    class StatusesController < BaseController
      EVENTS = %w[request build ready borrow check_in unresolve resolve].freeze

      def update
        event = params.require(:event)

        unless EVENTS.include?(event) && @reservation.manager.can?(event.to_sym)
          redirect_to default_reservation_tab_path(@reservation), error: "Can't #{event.humanize(capitalize: false)} a reservation with status #{@reservation.status}"
          return
        end

        saved = @reservation.transaction do
          @reservation.manager.trigger(event.to_sym) && @reservation.save || raise(ActiveRecord::Rollback)
        end

        if saved
          redirect_to default_reservation_tab_path(@reservation), success: "Reservation was successfully updated."
        else
          redirect_to default_reservation_tab_path(@reservation), error: "Reservation could not be updated: #{@reservation.errors.full_messages.join(", ")}"
        end
      end
    end
  end
end
