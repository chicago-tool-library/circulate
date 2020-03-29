module Admin
  class ItemHistoriesController < BaseController
    def show
      @item = Item.find(params[:item_id])
    end
  end
end
