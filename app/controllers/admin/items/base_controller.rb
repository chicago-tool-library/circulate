module Admin
  module Items
    class BaseController < Admin::BaseController
      before_action :load_item

      private

      def load_item
        @item = Item.find(params[:item_id])
      end
    end
  end
end
