module Admin
  module Items
    class HoldsController < BaseController
      before_action :set_item

      def index
        holds_scope = @item.holds.ordered_by_position.includes(:member)
        @holds =
          if params[:inactive]
            holds_scope.inactive
          else
            holds_scope.active
          end
      end

      def remove
        @hold = @item.holds.find(params[:hold_id])
        @hold.update(ended_at: Time.current)
        redirect_to admin_item_holds_path(@item), flash: {success: "Hold ended."}, status: :see_other
      end

      private

      def set_item
        @item = Item.find(params[:item_id])
      end
    end
  end
end
