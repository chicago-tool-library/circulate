# frozen_string_literal: true

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
          @new_hold.start! if @new_hold.ready_for_pickup?
          redirect_to item_path(@item), success: "Hold placed."
        else
          redirect_to item_path(@item), error: "Something went wrong!"
        end
      end
    end

    def destroy
      current_member.active_holds.find(params[:id]).destroy!
      redirect_to account_holds_path
    end

    def history
      @holds = current_member.inactive_holds.recent_first.includes(:item)
    end
  end
end
