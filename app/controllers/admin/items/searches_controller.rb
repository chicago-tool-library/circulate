module Admin
  module Items
    class SearchesController < Admin::BaseController
      include Pagy::Backend

      def show
        params[:q] ||= {}
        params[:q]["s"] ||= "number asc"
        params[:q]["status_in"] ||= %w[active pending maintenance]
        @q = Item.with_active_holds_count.ransack(params[:q])
        item_scope = @q.result.includes(:categories, :borrow_policy).with_attached_image
        @pagy, @items = pagy(item_scope)
      end
    end
  end
end
