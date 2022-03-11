module Admin
  class ItemHoldsController < BaseController
    def index
      @item = Item.find(params[:item_id])
      @holds = @item.holds.order(created_at: :asc)
      @holds =
        if params[:inactive]
          @holds.inactive
        else
          @holds.active
        end
    end
  end
end
