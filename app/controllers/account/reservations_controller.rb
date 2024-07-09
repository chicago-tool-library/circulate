module Account
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
    end

    def edit
    end

    def create
      @reservation = Reservation.new(reservation_params.merge(organization: Organization.first))

      if @reservation.save
        # TODO use the current user's actual organization
        redirect_to account_reservation_url(@reservation), notice: "Reservation was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @reservation.update(reservation_params)
        redirect_to account_reservation_url(@reservation), notice: "Reservation was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @reservation.destroy!

      redirect_to account_reservations_url, notice: "Reservation was successfully destroyed."
    end

    private

    def set_reservation
      @reservation = Reservation.find(params[:id])
    end

    def reservation_params
      params.require(:reservation).permit(:name, :started_at, :ended_at)
    end
  end
end
