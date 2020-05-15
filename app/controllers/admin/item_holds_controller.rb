module Admin
  class ItemHoldsController < BaseController
    def index
      @item = Item.find(params[:item_id])
      @holds = @item.holds.order(created_at: :asc)
    end
  end
end
