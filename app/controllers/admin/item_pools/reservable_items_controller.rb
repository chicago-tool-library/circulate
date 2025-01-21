module Admin
  module ItemPools
    class ReservableItemsController < BaseController
      before_action :set_reservable_item, only: %i[show edit update destroy]

      def index
      end

      def show
      end

      def new
        @reservable_item = @item_pool.reservable_items.new
      end

      def edit
      end

      def create
        @reservable_item = @item_pool.reservable_items.new(reservable_item_params.merge(creator: current_user))

        if @reservable_item.save
          redirect_to admin_item_pool_url(@item_pool), success: "Reservable item was successfully created."
        else
          render :new, status: :unprocessable_entity
        end
      end

      def update
        if @reservable_item.update(reservable_item_params)
          redirect_to admin_item_pool_url(@item_pool), success: "Reservable item was successfully updated."

        else
          render :edit, status: :unprocessable_entity
        end
      end

      def destroy
        @reservable_item.destroy!

        redirect_to admin_item_pool_url(@item_pool), success: "Reservable item was successfully destroyed."
      end

      private

      def set_reservable_item
        @reservable_item = @item_pool.reservable_items.find(params[:id])
      end

      def reservable_item_params
        params.require(:reservable_item).permit(:name, :status)
      end
    end
  end
end
