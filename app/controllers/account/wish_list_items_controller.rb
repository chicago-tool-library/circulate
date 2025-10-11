module Account
  class WishListItemsController < BaseController
    include Pagy::Backend

    def index
      scope = current_member.wish_list_items.includes(:item).strict_loading
      @pagy, @wish_list_items = pagy(scope, items: 20)
    end

    def create
      wish_list_item = WishListItem.new(wish_list_item_params)
      wish_list_item.member = current_member

      wish_list_item.save!

      respond_to do |format|
        format.html { redirect_to item_path(wish_list_item.item) }
        format.turbo_stream { render turbo_stream: [turbo_stream.replace("wish_list_item_show", partial: "items/wish_list_item_show", locals: {item: wish_list_item.item})] }
      end
    end

    private

    def wish_list_item_params
      params.expect(wish_list_item: [:item_id])
    end
  end
end
