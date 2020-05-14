module Admin
  class ReservationsController < BaseController
    include ActionView::RecordIdentifier

    before_action :load_member

    def index
      @reservations = @member.reservations.includes(:item)
    end

    def create
      @item = Item.find(new_reservation_params[:item_id])

      @reservation = Reservation.new(item: @item, member: @member, creator: current_user)

      if @reservation.save
        redirect_to admin_member_reservations_path(@member, anchor: dom_id(@reservation))
      else
        flash[:checkout_error] = @reservation.errors.full_messages_for(:item_id).join
        redirect_to admin_member_reservations_path(@member, anchor: "checkout")
      end
    end

    def destroy
      @reservation = @member.reservations.find(params[:id])

      @reservation.destroy!
      redirect_to admin_member_reservations_path(@reservation.member)
    end

    private

    def new_reservation_params
      params.require(:reservation).permit(:item_id)
    end

    def load_member
      @member = Member.find(params[:member_id])
    end
  end
end
