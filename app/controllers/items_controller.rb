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
