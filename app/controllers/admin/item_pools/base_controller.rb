module Admin
  module ItemPools
    class BaseController < Admin::BaseController
      before_action :load_item_pool

      private

      def load_item_pool
        @item_pool = ItemPool.find(params[:item_pool_id])
      end
    end
  end
end
