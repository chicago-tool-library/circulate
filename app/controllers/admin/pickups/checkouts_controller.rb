module Admin
  module Pickups
    class CheckoutsController < BaseController
      def create
        # TODO verify that the checkout is on the day of the reservation
        @pickup.transaction do
          @pickup.update(status: Pickup.statuses[:picked_up])
          @pickup.reservation_loans.each do |reservation_loan|
            reservation_loan.update!(checked_out_at: Time.current)
          end
        end

        redirect_to admin_pickup_path(@pickup), status: :see_other
      end
    end
  end
end
