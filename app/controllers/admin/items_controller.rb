module Admin
  class ItemsController < BaseController
    include Pagy::Backend

    before_action :set_item, only: [:show, :edit, :update, :destroy]

    # GET /items
    # GET /items.json
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

    # GET /items/1
    # GET /items/1.json
    def show
    end

    def number
      @item = Item.find(params[:item_id])
    end

    # GET /items/new
    def new
      if params[:item_id]
        item_to_duplicate = Item.find(params[:item_id])
        @item = Item.new(item_to_duplicate.attributes.except(:id).merge(category_ids: item_to_duplicate.category_ids))
      else
        @item = Item.new(category_ids: [params[:category_id]])
      end

      set_categories
    end

    # GET /items/1/edit
    def edit
      set_categories
    end

    # POST /items
    # POST /items.json
    def create
      @item = Item.new(item_params)

      respond_to do |format|
        if @item.save
          format.html { redirect_to admin_item_number_path(@item), success: "Item was successfully created." }
          format.json { render :show, status: :created, location: @item }
        else
          set_categories
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @item.errors, status: :unprocessable_entity }
        end
      end
    end

    # PATCH/PUT /items/1
    # PATCH/PUT /items/1.json
    def update
      respond_to do |format|
        if @item.update(item_params)
          @item.image.purge_later if all_item_params[:delete_image] == "1"

          format.html { redirect_to [:admin, @item], success: "Item was successfully updated." }
          format.json { render :show, status: :ok, location: @item }
        else
          set_categories
          format.html { render :edit }
          format.json { render json: @item.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /items/1
    # DELETE /items/1.json
    def destroy
      @item.destroy
      respond_to do |format|
        format.html { redirect_to [:admin, @item], warning: "Item was successfully destroyed." }
        format.json { head :no_content }
      end
    end

    private

    def set_item
      @item = Item.find(params[:id])
    end

    def set_categories
      @categories = CategoryNode.all
    end

    def item_params
      all_item_params.except(:delete_manual)
    end

    def all_item_params
      params.require(:item).permit(
        :name, :other_names, :description, :size, :brand, :model, :serial, :number, :image, :status, :strength,
        :power_source, :borrow_policy_id, :quantity, :checkout_notice, :delete_image, category_ids: []
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
