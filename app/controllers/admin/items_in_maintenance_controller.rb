module Admin
    class ItemsInMaintenanceController < BaseController
      def index
        @items = Item.in_maintenance
      end
    end
  end
  