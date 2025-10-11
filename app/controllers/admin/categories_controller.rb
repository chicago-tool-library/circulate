module Admin
  class CategoriesController < BaseController
    include ActionView::RecordIdentifier

    before_action :set_category, only: [:edit, :update, :destroy]

    def index
      @categories = CategoryNode.all.sorted
    end

    def new
      @category = Category.new
    end

    def edit
    end

    def create
      @category = Category.new(category_params)

      if @category.save
        redirect_to admin_categories_url(anchor: dom_id(@category)), status: :see_other
      else
        render :new, status: :unprocessable_content
      end
    end

    def update
      if @category.update(category_params)
        redirect_to admin_categories_url(anchor: dom_id(@category)), status: :see_other
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      @category.destroy
      redirect_to admin_categories_url, success: "Category was successfully destroyed.", status: :see_other
    end

    private

    def set_category
      @category = Category.find(params[:id])
    end

    def category_params
      params.require(:category).permit(:name, :slug, :parent_id)
    end
  end
end
