module Admin
  module Reservations
    class ItemPoolSearchesController < BaseController
      include Pagy::Backend

      def show
        item_pool_scope = ItemPool.all

        if params[:category]
          @category = CategoryNode.find_by(id: params[:category])
          redirect_to(items_path, error: "Category not found") && return unless @category

          item_pool_scope = @category.item_pools
        end

        item_pool_scope = item_pool_scope.includes(:categories).order(name: :asc)

        @pagy, @item_pools = pagy(item_pool_scope)
        @categories = CategoryNode.with_item_pools
      end
    end
  end
end
