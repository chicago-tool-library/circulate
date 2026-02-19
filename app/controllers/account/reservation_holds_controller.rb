module Account
  class ReservationHoldsController < BaseController
    def create
      @reservation = current_member.reservations.find(reservation_hold_params[:reservation_id])
      if !@reservation
        redirect_to item_pool_path(@reservation_hold.item_pool), error: "Reservation not found."
        return
      end

      # existing_reservation_hold = @reservation.reservation_holds.find_by(item_pool_id: reservation_hold_params[:item_pool_id])
      # if existing_reservation_hold
      #   @reservation_hold = existing_reservation_hold
      #   @reservation_hold.quantity += 1
      # else
      @reservation_hold = @reservation.reservation_holds.new(reservation_hold_params)
      # end

      if @reservation_hold.save
        redirect_to item_pool_path(@reservation_hold.item_pool), success: "#{@reservation_hold.item_pool.name} was added to your reservation."
      else
        redirect_to item_pool_path(@reservation_hold.item_pool), error: "#{@reservation_hold.item_pool.name} could not be added."
      end
    end

    def update
      @reservation_hold = current_member.reservation_holds.find(params[:id])
      if !@reservation_hold
        redirect_back_or_to account_reservations_url, error: "Reservation not found."
        return
      end

      if @reservation_hold.update(reservation_hold_params)
        redirect_to item_pool_path(@reservation_hold.item_pool), success: "#{@reservation_hold.item_pool.name} reservation hold was updated."
      else
        redirect_to item_pool_path(@reservation_hold.item_pool), error: "#{@reservation_hold.item_pool.name} reservation hold could not be updated."
      end
    end

    def destroy
      @reservation_hold = current_member.reservation_holds.find(params[:id])
      if !@reservation_hold
        redirect_back_or_to account_reservations_url, error: "Reservation not found."
        return
      end

      if @reservation_hold.destroy
        redirect_to item_pool_path(@reservation_hold.item_pool), success: "#{@reservation_hold.item_pool.name} reservation hold was removed."
      else
        redirect_to item_pool_path(@reservation_hold.item_pool), error: "#{@reservation_hold.item_pool.name} reservation hold could not be removed."
      end
    end

    private

    def reservation_hold_params
      params.require(:reservation_hold).permit(:item_pool_id, :reservation_id, :quantity)
    end
  end
end
