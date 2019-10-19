module Admin
  class ItemsController < BaseController
    include Pagy::Backend

    before_action :set_item, only: [:show, :edit, :update, :destroy]

    # GET /items
    # GET /items.json
    def index
      item_scope = Item.includes(:checked_out_exclusive_loan)

      if params[:tag]
        @tag = Tag.where(id: params[:tag]).first
        redirect_to(items_path, error: "Tag not found") && return unless @tag

        item_scope = @tag.items
      end

      item_scope = item_scope.includes(:tags, :borrow_policy).with_attached_image.order(index_order)

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
        @item = Item.new(item_to_duplicate.attributes.except(:id).merge(tag_ids: item_to_duplicate.tag_ids))
      else
        @item = Item.new(tag_ids: [params[:tag_id]])
      end

      set_tags
    end

    # GET /items/1/edit
    def edit
      set_tags
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
          set_tags
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
          format.html { redirect_to [:admin, @item], success: "Item was successfully updated." }
          format.json { render :show, status: :ok, location: @item }
        else
          set_tags
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

    # Use callbacks to share common setup or constraints between actions.
    def set_item
      @item = Item.find(params[:id])
    end

    def set_tags
      @tags = Tag.sorted_by_name
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def item_params
      params.require(:item).permit(
        :name, :description, :size, :brand, :model, :serial, :number, :image, :status, :strength,
        :borrow_policy_id, :quantity, tag_ids: []
      )
    end

    def index_order
      options = {
        "name" => "items.name ASC",
        "number" => "items.number ASC",
        "added" => "items.created_at DESC",
      }
      options.fetch(params[:sort]) { options["name"] }
    end
  end
end
