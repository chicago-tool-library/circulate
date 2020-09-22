class MemberHoldsController < ApplicationController
  def create
    if new_hold.save
      redirect_to item_path(item), success: "Hold placed."
    else
      redirect_to item_path(item), error: "Something went wrong!"
    end
  end

  private

  def item
    @item ||= Item.find(params[:item_id])
  end

  def new_hold
    @new_hold ||= Hold.new(item: item, member: current_member, creator: current_user)
  end
end