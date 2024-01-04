module Admin
  class ReservationsController < BaseController
    before_action :set_reservation, only: %i[show edit update destroy]

    def index
      @reservations = Reservation.all
    end

    def show
    end

    def new
      @reservation = Reservation.new
      @reservable_items = ReservableItem.all
    end

    def edit
      @reservable_items = ReservableItem.all
    end

    def create
      @reservation = Reservation.new(reservation_params)

      if @reservation.save
        redirect_to admin_reservation_url(@reservation), notice: "Reservation was successfully created."
      else
        @reservable_items = ReservableItem.all
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @reservation.update(reservation_params)
        redirect_to admin_reservation_url(@reservation), notice: "Reservation was successfully updated."
      else
        @reservable_items = ReservableItem.all
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @reservation.destroy!

      redirect_to admin_reservations_url, notice: "Reservation was successfully destroyed."
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_reservation
      @reservation = Reservation.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def reservation_params
      params.require(:reservation).permit(:name, :started_at, :ended_at, reservable_item_ids: [])
    end
  end
end
