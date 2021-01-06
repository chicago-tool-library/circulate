module Admin
  module Reports
    class ItemsInMaintenanceController < BaseController
      def index
        @items = Item.in_maintenance
      end
    end
  end
end
  