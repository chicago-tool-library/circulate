module Holds
  class ItemsController < BaseController
    include PortalRendering

    def create
      item_id = params[:item_id].to_i
      @item = Item.find(item_id)

      @requested_item_ids << @item.id
      load_requested_items

      render :items
    end

    def destroy
      item_id = params[:id].to_i
      @item = Item.find(item_id)

      @requested_item_ids.delete(@item.id)

      render :items
    end
  end
end
