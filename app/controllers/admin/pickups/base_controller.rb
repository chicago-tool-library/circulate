module Admin
  module Pickups
    class BaseController < Admin::BaseController
      before_action :set_pickup

      private

      def set_pickup
        @pickup = Pickup.find(params[:pickup_id])
      end
    end
  end
end
