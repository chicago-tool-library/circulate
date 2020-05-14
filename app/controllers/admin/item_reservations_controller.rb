module Admin
  class ItemReservationsController < BaseController
    def index
      @item = Item.find(params[:item_id])
      @reservations = @item.reservations.order(created_at: :asc)
    end
  end
end
