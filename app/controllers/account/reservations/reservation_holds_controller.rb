module Account
  module Reservations
    class ReservationHoldsController < BaseController
      before_action :set_reservation_hold, except: :create

      def show
        render_turbo_response :show
      end

      def edit
        render_turbo_response :edit
      end

      def update
        if @reservation_hold.update(reservation_hold_params)
          render_turbo_response :show
        else
          render_turbo_response :edit
        end
      end

      def create
        result = ReservationLending.create_reservation_hold(
          reservation: @reservation,
          item_pool_id: reservation_hold_params[:item_pool_id],
          quantity: reservation_hold_params[:quantity]
        )

        if result.success?
          redirect_to account_reservation_path(@reservation), status: :see_other
        else
          @reservation_hold = result.error
          render_turbo_response :create_error
        end
      end

      def destroy
        if @reservation_hold.destroy
          render_turbo_response :destroy
        else
          render_turbo_response :edit
        end
      end

      private

      def set_reservation_hold
        @reservation_hold = @reservation.reservation_holds.find(params[:id])
      end

      def reservation_hold_params
        params.require(:reservation_hold).permit(:quantity, :item_pool_id)
      end
    end
  end
end
