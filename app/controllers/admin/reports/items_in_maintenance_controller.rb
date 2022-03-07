module Admin
  module Reports
    class ItemsInMaintenanceController < BaseController
      def index
        @items = Item.in_maintenance.merge(Item.left_joins(:tickets)).uniq
      end
    end
  end
end
