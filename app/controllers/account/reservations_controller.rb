module Account
  class ReservationsController < BaseController
    include Pagy::Backend

    before_action :set_reservation, only: %i[show edit update destroy]

    def index
      reservations_scope = Reservation.includes(reservation_holds: :item_pool).by_start_date
      @pagy, @reservations = pagy(reservations_scope, items: 50)
    end

    def show
    end

    def new
      @reservation = Reservation.new
      set_reservation_slots
    end

    def edit
      set_reservation_slots
    end

    def create
      @reservation = Reservation.new(reservation_params.merge(organization_id: Organization.first.id, submitted_by: current_user))

      if @reservation.save
        # TODO use the current user's actual organization
        redirect_to account_reservation_url(@reservation), notice: "Reservation was successfully created."
      else
        set_reservation_slots
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @reservation.update(reservation_params)
        redirect_to account_reservation_url(@reservation), notice: "Reservation was successfully updated."
      else
        set_reservation_slots
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @reservation.destroy!

      redirect_to account_reservations_url, notice: "Reservation was successfully destroyed."
    end

    private

    def set_reservation
      @reservation = Reservation.find(params[:id])
    end

    def reservation_params
      params.require(:reservation).permit(:name, :started_at, :ended_at, :pickup_event_id, :dropoff_event_id)
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
