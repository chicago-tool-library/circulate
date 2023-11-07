module Admin
  module Items
    class HoldsController < BaseController
      def index
        @item = Item.find(params[:item_id])
        holds_scope = @item.holds.ordered_by_position.includes(:member)
        @holds =
          if params[:inactive]
            holds_scope.inactive
          else
            holds_scope.active
          end
      end
    end
  end
end
