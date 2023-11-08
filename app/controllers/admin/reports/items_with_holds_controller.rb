module Admin
  module Reports
    class ItemsWithHoldsController < BaseController
      include Pagy::Backend

      def index
        items_scope = Item.joins(:active_holds).where.not(active_holds: {id: nil})
          .includes(:borrow_policy)
          .select("items.*, COUNT(active_holds.id) AS active_holds_count")
          .group("items.id")
          .order("COUNT(active_holds.id) DESC")
          .distinct
        @pagy, @items_with_active_holds = pagy(items_scope, items: 100)
      end
    end
  end
end
