module Account
  class CurrentReservationsController < BaseController
    def create
      @reservation = current_member.reservations.find(params[:reservation_id])
      session[:reservation_id] = @reservation.id
      if params[:item_pool_id]
        redirect_to item_pool_path(params[:item_pool_id]), success: "Switched to selected reservation."
      else
        redirect_to item_pools_path, success: "Switched to selected reservation."
      end
    end

    def destroy
      session.delete(:reservation_id)
      redirect_back_or_to item_pools_path
    end
  end
end
