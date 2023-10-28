module Admin
  module Items
    class HistoriesController < BaseController
      def show
        @item = Item.find(params[:item_id])
        @audits = @item.audits.includes(:user)
      end
    end
  end
end
