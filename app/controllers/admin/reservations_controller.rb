module Admin
  class ReservationsController < BaseController
    include Pagy::Backend

    before_action :set_reservation, only: %i[show edit update destroy]

    def index
      reservations_scope = Reservation.includes(reservation_holds: :item_pool).by_start_date
      @pagy, @reservations = pagy(reservations_scope, items: 50)
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
        ReservationMailer.with(reservation: @reservation).reservation_requested.deliver_later
        redirect_to admin_reservation_url(@reservation), success: "Reservation was successfully created."
      else
        @item_pools = ItemPool.all
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @reservation.update(reservation_params)
        redirect_to admin_reservation_url(@reservation), success: "Reservation was successfully updated."
      else
        @item_pools = ItemPool.all
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @reservation.destroy!

      redirect_to admin_reservations_url, success: "Reservation was successfully destroyed."
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
