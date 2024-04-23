module Admin
  class ReservationsController < BaseController
    before_action :set_reservation, only: %i[show edit update destroy]

    def index
      @reservations = Reservation.includes(reservation_holds: :item_pool)
    end

    def show
    end

    def new
      @reservation = Reservation.new
      @item_pools = ItemPool.all
    end

    def edit
      @item_pools = ItemPool.all
    end

    def create
      @reservation = Reservation.new(reservation_params)

      if @reservation.save
        redirect_to admin_reservation_url(@reservation), notice: "Reservation was successfully created."
      else
        @item_pools = ItemPool.all
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @reservation.update(reservation_params)
        redirect_to admin_reservation_url(@reservation), notice: "Reservation was successfully updated."
      else
        @item_pools = ItemPool.all
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @reservation.destroy!

      redirect_to admin_reservations_url, notice: "Reservation was successfully destroyed."
    end

    def append_reservation_hold
      @item_pool = ItemPool.find(params[:item_pool_id])
    end

    private

    def set_reservation
      @reservation = Reservation.find(params[:id])
    end

    def reservation_params
      params.require(:reservation).permit(:name, :started_at, :ended_at, reservation_holds_attributes: [:id, :quantity, :item_pool_id, :_destroy])
    end
  end
end
