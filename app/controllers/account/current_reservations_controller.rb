module Account
  class CurrentReservationsController < BaseController
    def create
      @reservation = current_member.reservations.find(params[:reservation_id])
      session[:reservation_id] = @reservation.id
      redirect_to item_pools_path
    end

    def destroy
      session.delete(:reservation_id)
      redirect_to item_pools_path
    end
  end
end
