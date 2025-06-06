module Account
  class HoldsController < BaseController
    include Pagy::Backend

    def index
      @holds = current_member.active_holds.recent_first.joins(:item).merge(Item.holdable)
    end

    def create
      @item = Item.find(params[:item_id])

      unless @item.holds_enabled
        redirect_to item_path(@item), error: "Can't be placed on hold", status: :see_other
        return
      end

      @new_hold = Hold.new(item: @item, member: current_member, creator: current_user)

      @new_hold.transaction do
        if @new_hold.save
          ahoy.track "Placed hold", hold_id: @new_hold.id
          @new_hold.start! if @new_hold.ready_for_pickup?
          redirect_to item_path(@item), success: "Hold placed.", status: :see_other
        else
          redirect_to item_path(@item), error: "Something went wrong!", status: :see_other
        end
      end
    end

    def destroy
      hold = current_member.active_holds.find(params[:id])
      hold.cancel!

      redirect_to account_holds_path, status: :see_other
    end

    def history
      @pagy, @holds = pagy(current_member.inactive_holds.recent_first.includes(:item))
    end
  end
end
