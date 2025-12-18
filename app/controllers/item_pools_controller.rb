class ItemPoolsController < ApplicationController
  include Pagy::Backend

  before_action :set_item_pool, only: :show

  def index
    item_pool_scope = ItemPool.all

    if params[:category]
      @category = CategoryNode.where(id: params[:category]).first
      redirect_to(items_path, error: "Category not found") && return unless @category

      item_pool_scope = @category.item_pools
    end

    item_pool_scope = item_pool_scope.includes(:categories).order("name ASC")

    @pagy, @item_pools = pagy(item_pool_scope)
    @categories = CategoryNode.with_item_pools
  end

  def show
    @reservation_hold = ReservationHold.new
  end

  private

  def set_item_pool
    @item_pool = ItemPool.find(params[:id])
  end
end
