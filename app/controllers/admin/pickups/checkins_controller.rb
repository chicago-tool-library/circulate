module Admin
  module Pickups
    class CheckinsController < BaseController
      def create
        @pickup.transaction do
          @pickup.update(status: Pickup.statuses[:returned])
          @pickup.reservation_loans.each do |reservation_loan|
            reservation_loan.update!(checked_in_at: Time.current)
          end
        end

        redirect_to admin_pickup_path(@pickup), status: :see_other
      end
    end
  end
end
