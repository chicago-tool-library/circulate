module Admin
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
        @reservation_hold = @reservation.reservation_holds.new(reservation_hold_params)

        if @reservation_hold.save
          redirect_to admin_reservation_path(@reservation), status: :see_other
        else
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
