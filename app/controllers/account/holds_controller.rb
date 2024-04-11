module Account
  class HoldsController < BaseController
    def index
      @holds = current_member.active_holds.recent_first.includes(:item)
    end

    def create
      @item = Item.find(params[:item_id])
      @new_hold = Hold.new(item: @item, member: current_member, creator: current_user)

      @new_hold.transaction do
        if @new_hold.save
          Ahoy.track "Placed hold", hold_id: @new_hold.id
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
      @holds = current_member.inactive_holds.recent_first.includes(:item)
    end
  end
end
