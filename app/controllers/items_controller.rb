class ItemsController < ApplicationController
  include Pagy::Backend

  def index
    item_scope = Item.listed_publicly

    if params[:tag]
      @tag = Tag.where(id: params[:tag]).first
      redirect_to(items_path, error: "Tag not found") && return unless @tag

      item_scope = @tag.items
    end

    item_scope = item_scope.includes(:tags, :borrow_policy).with_attached_image.order(index_order)

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
      "added" => "items.created_at DESC",
    }
    options.fetch(params[:sort]) { options["name"] }
  end
end
