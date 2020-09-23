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

  def show; end

  private

  delegate :holds, to: :current_member, prefix: true, allow_nil: true, private: true

  def index_order
    options = {
      "name" => "items.name ASC",
      "number" => "items.number ASC",
      "added" => "items.created_at DESC"
    }
    options.fetch(params[:sort]) { options["name"] }
  end

  def on_hold_by_current_member?
    current_item_hold_count.positive?
  end

  helper_method def current_item_hold_count
    @current_item_hold_count ||= current_member_holds.active_hold_count_for_item(item).to_i
  end

  helper_method def item
    @item ||= Item.listed_publicly.find(params[:id])
  end

  helper_method def place_hold_partial
    if user_signed_in? && item.allow_multiple_holds_per_member?
      "items/place_hold_on/item_that_allows_multiple_holds"
    elsif user_signed_in? && on_hold_by_current_member?
      "items/place_hold_on/item_already_with_a_hold"
    elsif user_signed_in?
      "items/place_hold_on/item"
    else
      "items/place_hold_on/not_logged_in"
    end
  end
end
