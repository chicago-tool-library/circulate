module Account
  class HoldsController < BaseController
    def create
      @item = Item.find(params[:item_id])
      @new_hold = Hold.new(item: @item, member: current_member, creator: current_user)

      flash_message = if @new_hold.save
        {success: "Hold placed."}
      else
        {error: "Something went wrong!"}
      end

      redirect_to item_path(@item), flash: flash_message
    end

    def destroy
      current_member.holds.find(params[:id]).destroy!
      redirect_to member_loans_path
    end
  end
end