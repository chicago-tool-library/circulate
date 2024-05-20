module Admin
  module Reservations
    class PickupsController < BaseController
      def show
        # eager load reservation_holds: [:item_pool, reservation_loans: :reservable_item]
      end
    end
  end
end
