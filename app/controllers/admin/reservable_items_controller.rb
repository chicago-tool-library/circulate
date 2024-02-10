module Admin
  class ReservableItemsController < BaseController
    before_action :set_reservable_item, only: %i[show edit update destroy]

    def index
      @reservable_items = ReservableItem.all
    end

    def show
    end

    def new
      @reservable_item = ReservableItem.new
    end

    def edit
    end

    def create
      @reservable_item = ReservableItem.new(reservable_item_params)

      if @reservable_item.save
        redirect_to admin_reservable_item_url(@reservable_item), success: "Reservable item was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @reservable_item.update(reservable_item_params)
        redirect_to admin_reservable_item_url(@reservable_item), success: "Reservable item was successfully updated."

      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @reservable_item.destroy!

      redirect_to admin_reservable_items_url, success: "Reservable item was successfully destroyed."
    end

    private

    def set_reservable_item
      @reservable_item = ReservableItem.find(params[:id])
    end

    def reservable_item_params
      params.require(:reservable_item).permit(:name, :item_pool_id)
    end
  end
end
