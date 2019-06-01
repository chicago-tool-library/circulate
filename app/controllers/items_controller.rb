class ItemsController < ApplicationController
  before_action :set_item, only: [:show, :edit, :update, :destroy]

  # GET /items
  # GET /items.json
  def index
    @items = Item.includes(:categories).all
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
    @item = Item.new
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
        format.html { redirect_to item_number_path(@item), success: 'Item was successfully created.' }
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
        format.html { redirect_to @item, success: 'Item was successfully updated.' }
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
      format.html { redirect_to items_url, warning: 'Item was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_item
      @item = Item.find(params[:id])
    end

    def set_categories
      @categories = Category.alpha_tree
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def item_params
      params.require(:item).permit(
        :name, :description, :size, :brand, :model, :serial, :number, :image, :status,
        :borrow_policy_id, category_ids:[])
    end
end
