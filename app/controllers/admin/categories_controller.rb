module Admin
  class CategoriesController < BaseController
    include ActionView::RecordIdentifier

    before_action :set_category, only: [:show, :edit, :update, :destroy]

    def index
      @categories = CategoryNode.all
    end

    def show
    end

    def new
      @category = Category.new
      set_all_categories
    end

    def edit
      set_all_categories
    end

    def create
      @category = Category.new(category_params)

      if @category.save
        redirect_to admin_categories_url(anchor: dom_id(@category)), success: "Category was successfully created."
      else
        set_all_categories
        render :new
      end
    end

    def update
      if @category.update(category_params)
        redirect_to admin_categories_url(anchor: dom_id(@category)), success: "Category was successfully updated."
      else
        set_all_categories
        render :edit
      end
    end

    def destroy
      @category.destroy
      redirect_to admin_categories_url, success: "Category was successfully destroyed."
    end

    private

    def set_category
      @category = Category.find(params[:id])
    end

    def set_all_categories
      @all_categories = Category.sorted_by_name
    end

    def category_params
      params.require(:category).permit(:name, :slug, :parent_id)
    end
  end
end
