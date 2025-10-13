module Account
  class WishListItemsController < BaseController
    include Pagy::Backend

    def index
      scope = current_member.wish_list_items.includes(item: [:borrow_policy, :active_holds, :checked_out_exclusive_loan, :categories]).strict_loading
      @pagy, @wish_list_items = pagy(scope, items: 20)
    end

    def create
      wish_list_item = WishListItem.new(wish_list_item_params)
      wish_list_item.member = current_member

      wish_list_item.save!

      item = wish_list_item.item

      respond_to do |format|
        format.html { redirect_to item_path(wish_list_item.item) }
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("wish_list_item_show", partial: "items/wish_list_item_show", locals: {item:, wish_list_item:}),
            turbo_stream.replace("#{helpers.dom_id(item)}_wish_list_items_index", partial: "items/wish_list_items_index", locals: {item:, wish_list_item:})
          ]
        end
      end
    end

    def destroy
      wish_list_item = current_member.wish_list_items.find(params.expect(:id))

      wish_list_item.destroy!

      item = wish_list_item.item

      respond_to do |format|
        format.html { redirect_to account_wish_list_items_path }
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.remove(helpers.dom_id(wish_list_item)),
            turbo_stream.replace("wish_list_item_show", partial: "items/wish_list_item_show", locals: {item:, wish_list_item: nil}),
            turbo_stream.replace("#{helpers.dom_id(item)}_wish_list_items_index", partial: "items/wish_list_items_index", locals: {item:, wish_list_item: nil})
          ]
        end
      end
    end

    private

    def wish_list_item_params
      params.expect(wish_list_item: [:item_id])
    end
  end
end
