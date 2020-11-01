class ItemsController < ApplicationController
  include Pagy::Backend

  def index
    item_scope = Item.listed_publicly.includes(:checked_out_exclusive_loan)

    if params[:category]
      @category = CategoryNode.where(id: params[:category]).first
      redirect_to(items_path, error: "Category not found") && return unless @category

      item_scope = @category.items
    end

    item_scope = item_scope.includes(:categories, :borrow_policy).with_attached_image.order(index_order)

    @categories = CategoryNode.all
    @pagy, @items = pagy(item_scope)
  end

  def show
    @item = Item.listed_publicly.find(params[:id])

    if user_signed_in?
      @current_hold = current_member.holds.active.where(item_id: @item.id).first
      @current_hold_count = current_member.holds.active_hold_count_for_item(@item).to_i
    end
  end

  private

  def index_order
    options = {
      "name" => "items.name ASC",
      "number" => "items.number ASC",
      "added" => "items.created_at DESC"
    }
    options.fetch(params[:sort]) { options["name"] }
  end
end
