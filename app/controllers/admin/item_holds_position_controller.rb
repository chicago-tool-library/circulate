module Admin
  class ItemHoldsPositionController < BaseController
    include PortalRendering

    def update
      @item = Item.find(params[:item_id])
      @hold = @item.active_holds.find(params[:hold_id])
      @hold.insert_at(params[:position].to_i)

      @holds = @item.active_holds.ordered_by_position.includes(:member)

      # Not rendering into a portal, but this prevents the Rails UJS code from replacing the entire page
      # with this partial.
      render_to_portal "admin/item_holds/holds_rows", table_row: true
    end
  end
end
