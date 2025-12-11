module Admin
  class ReservationsController < BaseController
    include Pagy::Backend
    include ReservationsHelper

    before_action :set_reservation, only: %i[show edit update destroy]

    def index
      reservations_scope = Reservation.includes(:member, reservation_holds: :item_pool).by_start_date
      @pagy, @reservations = pagy(reservations_scope, items: 50)
    end

    def show
    end

    def new
      @reservation = Reservation.new
      @item_pools = ItemPool.all
      set_answers
      set_reservation_slots
    end

    def edit
      @item_pools = ItemPool.all
      set_answers
      set_reservation_slots
    end

    def create
      @reservation = Reservation.new(reservation_params)

      if @reservation.save
        redirect_to admin_reservation_url(@reservation), success: "Reservation was successfully created."
      else
        @item_pools = ItemPool.all
        set_answers
        set_reservation_slots
        render :new, status: :unprocessable_content
      end
    end

    def update
      if @reservation.update(reservation_params)
        redirect_to default_reservation_tab_path(@reservation), success: "Reservation was successfully updated."
      else
        @item_pools = ItemPool.all
        set_answers
        set_reservation_slots
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      @reservation.destroy!

      redirect_to admin_reservations_url, success: "Reservation was successfully destroyed."
    end

    private

    def set_reservation
      @reservation = Reservation.find(params[:id])
    end

    def reservation_params
      params.require(:reservation).permit(:name,
        :dropoff_event_id,
        :ended_at,
        :pickup_event_id,
        :started_at,
        :member_id,
        answers_attributes: [:id, :stem_id, :value],
        reservation_holds_attributes: [:id, :quantity, :item_pool_id, :_destroy])
    end

    def set_answers
      @answers = @reservation.answers.includes(:stem).presence || Question.all.order(:name).where(archived_at: nil).includes(:stem).map { |question| Answer.new(reservation: @reservation, stem: question.stem) }
    end

    def set_reservation_slots
      events = Event.appointment_slots.upcoming.to_a + Event.where(id: [@reservation.pickup_event_id, @reservation.dropoff_event_id]).to_a

      @reservation_slots = events.group_by { |event| event.start.to_date }.map { |date, events|
        times = events.map { |event| [helpers.format_event_times(event), event.id] }
        [date.strftime("%A, %B %-d, %Y"), times]
      }
    end
  end
end
