module Admin
  module Reservations
    class ReservationLoansController < BaseController
      include Sounds

      before_action :set_reservation_loan, only: :destroy

      def index
        # TODO some eager loading?
      end

      # There are two wolves inside this method. If :reservation_hold_id is passed, it means
      # that we're creating a ReservationLoan for an ItemPool without uniquely numbered items.
      # Otherwise, we're creating a ReservationLoan for an individual ReservableItem.
      def create
        @sound_type = success_sound_path
        if (reservation_hold_id = reservation_loan_params[:reservation_hold_id])
          @reservation_hold = @reservation.reservation_holds.find(reservation_hold_id)

          # TODO make quantity something provided by UI
          @reservation_loan = @reservation.reservation_loans.new(
            reservation_hold: @reservation_hold,
            quantity: @reservation_hold.quantity
          )
        elsif reservation_loan_params[:reservable_item_number].blank?
          render_form_with_error("please enter an item number")
          return
        else
          @reservable_item = ReservableItem.find_by(number: reservation_loan_params[:reservable_item_number])
          if !@reservable_item
            render_form_with_error("no item found with this number")
            return
          end

          @reservation_hold = @reservation.reservation_holds.find_by(item_pool_id: @reservable_item.item_pool_id)
          if !@reservation_hold
            pending_item = @reservation.pending_reservation_items.new(
              reservable_item: @reservable_item,
              created_by: current_user
            )
            if pending_item.save
              @sound_type = neutral_sound_path
              respond_to do |format|
                format.turbo_stream
              end
            else
              render_form_with_error("already associated with a reservation")
            end
            return
          end

          @reservation_loan = @reservation.reservation_loans.new(
            reservable_item: @reservable_item,
            reservation_hold: @reservation_hold
          )
        end

        if @reservation_loan.save
          respond_to do |format|
            format.turbo_stream
          end
        else
          @sound_type = failure_sound_path
          render_form
        end
      end

      def destroy
        @reservation_loan.destroy!

        @reservation_hold = @reservation_loan.reservation_hold

        @sound_type = removed_sound_path

        respond_to do |format|
          format.turbo_stream do
            render :create
          end
        end
      end

      private

      def render_form_with_error(message)
        @sound_type = failure_sound_path
        @reservation_loan = ReservationLoan.new
        @reservation_loan.errors.add(:reservable_item_number, message)
        render_form
      end

      def render_form
        render_turbo_response :create_error, status: :unprocessable_entity
      end

      def set_reservation_loan
        @reservation_loan = @reservation.reservation_loans.find(params[:id])
      end

      def reservation_loan_params
        params.require(:reservation_loan).permit(:reservable_item_number, :reservation_hold_id)
      end
    end
  end
end
