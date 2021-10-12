class ItemsController < ApplicationController
  include Pagy::Backend

  def index
    item_scope = Item.listed_publicly.includes(:checked_out_exclusive_loan)

    if params[:filter] == "active"
      item_scope = item_scope.active.without_holds
    end

    if params[:category]
      @category = CategoryNode.where(id: params[:category]).first
      redirect_to(items_path, error: "Category not found") && return unless @category

      if params[:filter] == "active"
        item_scope = @category.items.active.listed_publicly.distinct
      else
        item_scope = @category.items.listed_publicly.distinct
      end
    end

    item_scope = item_scope.includes(:categories, :borrow_policy, :active_holds).with_attached_image.order(index_order)

    @categories = CategoryNode.with_items
    @pagy, @items = pagy(item_scope)
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
