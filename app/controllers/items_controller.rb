class ItemsController < ApplicationController
  include Pagy::Backend

  def index
    if params[:category]
      @category = CategoryNode.where(id: params[:category]).first
      redirect_to(items_path, error: "Category not found") && return unless @category
    end
    @categories = CategoryNode.with_items
    items = Item.for_inventory(filter: params[:filter], category: @category).order(index_order)
    @pagy, @items = pagy(items)
  end

  def show
    @item = Item.listed_publicly.find(params[:id])

    if user_signed_in?
      @current_hold = current_member.active_holds.active.where(item_id: @item.id).first
      @current_hold_count = current_member.active_holds.active_hold_count_for_item(@item).to_i
    end
  end

  private

  def index_order
    options = {
      "name" => "items.name ASC",
      "number" => "items.number ASC",
      "added" => "items.created_at DESC"
    }
    options.fetch(params[:sort]) { options["added"] }
  end
end
