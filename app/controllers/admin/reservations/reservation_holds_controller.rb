module Admin
  module Reservations
    class ReservationHoldsController < BaseController
      before_action :set_reservation_hold

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

      # def create
      #   @reservation_hold = @reservation.reservation_holds.new(reservation_hold_params)

      #   if @reservation_hold.save
      #     respond_to do |format|
      #       format.turbo_stream
      #     end
      #   else
      #     render_form
      #   end
      # end

      # def destroy
      #   @reservation_hold.destroy!

      #   respond_to do |format|
      #     format.turbo_stream do
      #       render :create
      #     end
      #   end
      # end

      private

      # def render_form_with_error(message)
      #   @reservation_loan = ReservationLoan.new
      #   @reservation_loan.errors.add(:reservable_item_id, message)
      #   render_form
      # end

      # def render_form
      #   render partial: "admin/reservations/reservation_holds/form", locals: {reservation: @reservation, reservation_hold: @reservation_hold}, status: :unprocessable_entity
      # end

      def set_reservation_hold
        @reservation_hold = @reservation.reservation_holds.find(params[:id])
      end

      def reservation_hold_params
        params.require(:reservation_hold).permit(:quantity, :item_pool_id)
      end
    end
  end
end
