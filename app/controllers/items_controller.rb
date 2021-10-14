class ItemsController < ApplicationController
  include Pagy::Backend

  def index
    item_scope = Item.listed_publicly.includes(:checked_out_exclusive_loan)
    item_ids_to_remove = []

    if params[:filter] == "active"
      uniquely_numbered_items = item_scope.active.with_uniquely_numbered_borrow_policy.pluck(:id)
      items_with_active_holds = item_scope.active.with_active_holds.pluck(:id)
      item_ids_to_remove = uniquely_numbered_items.intersection(items_with_active_holds)
      items_not_active = Item.not_active.pluck(:id)
      items_not_active.each do |item|
        item_ids_to_remove << item
      end
    end

    if params[:category]
      @category = CategoryNode.where(id: params[:category]).first
      redirect_to(items_path, error: "Category not found") && return unless @category

      if params[:filter] == "active"
        item_scope = @category.items.active.listed_publicly.distinct
        uniquely_numbered_items = @category.items.active.with_uniquely_numbered_borrow_policy.pluck(:id)
        items_with_active_holds = @category.items.active.with_active_holds.pluck(:id)
        item_ids_to_remove = uniquely_numbered_items.intersection(items_with_active_holds)
      else
        item_scope = @category.items.listed_publicly.distinct
      end
    end

    # Some products are always available, for all intents and purposes. For a tool library, this includes things like
    # screwdrivers and other smaller hand tools.
    uncounted_items = Item.uncounted.pluck(:id)

    without_rejected = item_scope.pluck(:id).reject { |item| item_ids_to_remove.include? item }
    uncounted_items.each do |item|
      without_rejected << item
    end

    items_to_display = Item.where(id: without_rejected).includes(:categories, :borrow_policy, :active_holds).with_attached_image.order(index_order)

    @categories = CategoryNode.with_items
    @pagy, @items = pagy(items_to_display)
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
