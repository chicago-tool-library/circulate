module Admin
  class ItemPoolsController < BaseController
    include Pagy::Backend

    before_action :set_item_pool, only: %i[show edit update destroy]

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
    end

    def new
      @item_pool = ItemPool.new
      set_categories
      set_reservation_policy_options
    end

    def edit
      set_categories
      set_reservation_policy_options
    end

    def create
      @item_pool = ItemPool.new(item_pool_params.merge(creator: current_user))

      if @item_pool.save
        redirect_to admin_item_pool_url(@item_pool), success: "Item pool was successfully created."
      else
        set_categories
        set_reservation_policy_options
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @item_pool.update(item_pool_params)
        redirect_to admin_item_pool_url(@item_pool), success: "Item pool was successfully updated."
      else
        set_categories
        set_reservation_policy_options
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @item_pool.destroy!

      redirect_to admin_item_pools_url, success: "Item pool was successfully destroyed."
    end

    private

    def set_item_pool
      @item_pool = ItemPool.find(params[:id])
    end

    def item_pool_params
      params.require(:item_pool).permit(
        :name, :other_names, :description, :size, :brand, :model, :strength,
        :power_source, :uniquely_numbered, :unnumbered_count,
        :location_shelf, :location_area, :url,
        :purchase_link, :reservation_policy_id, category_ids: []
      )
    end

    def set_categories
      set_reservation_policy_options
      @categories = CategoryNode.all
    end

    def set_reservation_policy_options
      @reservation_policy_options = ReservationPolicy.all.order(:name).map do |reservation_policy|
        [reservation_policy.name, reservation_policy.id]
      end
    end
  end
end
