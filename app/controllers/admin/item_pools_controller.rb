module Admin
  class ItemPoolsController < BaseController
    before_action :set_item_pool, only: %i[show edit update destroy]

    def index
      @item_pools = ItemPool.all
    end

    def show
      reserved_by_date = @item_pool.reserved_by_date(Time.current.beginning_of_month, Time.current.end_of_month)
      @month_calendar = GroupLending::MonthCalendar.new(reserved_by_date)
    end

    def new
      @item_pool = ItemPool.new
    end

    def edit
    end

    def create
      @item_pool = ItemPool.new(item_pool_params.merge(creator: current_user))

      if @item_pool.save
        redirect_to admin_item_pool_url(@item_pool), success: "Item pool was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @item_pool.update(item_pool_params)
        redirect_to admin_item_pool_url(@item_pool), success: "Item pool was successfully updated."
      else
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
      params.require(:item_pool).permit(:name)
    end
  end
end
