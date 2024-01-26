module Admin
  class PickupsController < BaseController
    before_action :set_pickup, only: %i[show edit update destroy]

    def index
      @pickups = Pickup.all
    end

    def show
    end

    def edit
    end

    def create
      # only allow one pickup per reservation
      @reservation = Reservation.find(params[:reservation_id])
      if @reservation.pickup
        redirect_back_or_to(admin_pickups_url, error: "That reservation already has a pickup")
        return
      end

      @pickup = Pickup.new(creator: current_user, reservation: @reservation)

      if @pickup.save
        redirect_to admin_pickup_url(@pickup), success: "Pickup was successfully created."
      else
        redirect_back_or_to(admin_pickups_url)
      end
    end

    def update
      if @pickup.update(pickup_params)
        redirect_to admin_pickup_url(@pickup), success: "Pickup was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @pickup.destroy!

      redirect_to admin_pickups_url, success: "Pickup was successfully destroyed."
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_pickup
      @pickup = Pickup.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def pickup_params
      params.require(:pickup).permit(:status)
    end
  end
end
