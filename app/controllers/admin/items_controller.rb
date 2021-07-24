module Admin
  class ItemsController < BaseController
    include Pagy::Backend

    before_action :set_item, only: [:show, :edit, :update, :destroy]

    def index
      item_scope = Item.includes(:checked_out_exclusive_loan)

      if params[:category]
        @category = CategoryNode.where(id: params[:category]).first
        redirect_to(items_path, error: "Category not found") && return unless @category

        item_scope = @category.items
      end

      item_scope = item_scope.includes(:categories, :borrow_policy).with_attached_image.order(index_order)

      @pagy, @items = pagy(item_scope)
    end

    def show
    end

    def number
      @item = Item.find(params[:item_id])
    end

    def new
      if params[:item_id]
        item_to_duplicate = Item.find(params[:item_id])
        @item = Item.new(item_to_duplicate.attributes.except(:id).merge(category_ids: item_to_duplicate.category_ids))
      else
        @item = Item.new(category_ids: [params[:category_id]])
      end

      set_categories
    end

    def edit
      set_categories
    end

    def create
      @item = Item.new(item_params)

      if @item.save
        redirect_to admin_item_number_path(@item), success: "Item was successfully created."
      else
        set_categories
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @item.update(item_params)
        @item.image.purge_later if all_item_params[:delete_image] == "1"

        redirect_to [:admin, @item], success: "Item was successfully updated."
      else
        set_categories
        render :edit
      end
    end

    def destroy
      @item.destroy
      redirect_to [:admin, @item], warning: "Item was successfully destroyed."
    end

    private

    def set_item
      @item = Item.find(params[:id])
    end

    def set_categories
      @categories = CategoryNode.all
    end

    def item_params
      all_item_params.except(:delete_image)
    end

    def all_item_params
      params.require(:item).permit(
        :name, :other_names, :description, :size, :brand, :model, :serial, :number, :image, :status, :strength,
        :power_source, :borrow_policy_id, :quantity, :checkout_notice, :delete_image, :location_shelf, :location_area, category_ids: []
      )
    end

    def index_order
      options = {
        "name" => "items.name ASC",
        "number" => "items.number ASC",
        "added" => "items.created_at DESC"
      }
      options.fetch(params[:sort]) { options["name"] }
    end
  end
end
