module Admin
  class CampingGearController < BaseController
    def index
      @current_day = Date.parse(params[:day] ||= Time.current.to_date.to_s)

      if Myturn.configured?
        client = Myturn::Client.new
        # Fetch a window around the current day so we catch both pickups and dropoffs.
        # A reservation starting 30 days ago with a long loan could have a dropoff today.
        window_start = @current_day - 30.days
        window_end = @current_day + 30.days
        all_reservations = client.reservations(from_date: window_start, to_date: window_end)
          .select { |r| r["pickupLocation"] == "Camping Gear" }

        @pickups = all_reservations.select { |r| pickup_date(r) == @current_day }
          .sort_by { |r| r["pickupStartTime"].to_s }

        @dropoffs = all_reservations.select { |r| dropoff_date(r) == @current_day }
          .sort_by { |r| r["pickupStartTime"].to_s }
      else
        @pickups = []
        @dropoffs = []
        @configuration_missing = true
      end
    rescue => e
      Rails.logger.error "MyTurn API error: #{e.message}"
      @pickups = []
      @dropoffs = []
      @api_error = e.message
    end

    private

    helper_method def previous_day
      @current_day - 1.day
    end

    helper_method def next_day
      @current_day + 1.day
    end

    helper_method def current_day_label
      if @current_day == Date.current
        "Today"
      elsif @current_day == 1.day.from_now.to_date
        "Tomorrow"
      else
        l @current_day, format: :with_weekday
      end
    end

    helper_method def myturn_reservation_url(reservation)
      "#{Myturn::BASE_URL}/library/orgInventory/editReservation/#{reservation["id"]}"
    end

    def pickup_date(reservation)
      Time.zone.parse(reservation["dateTime"]).to_date
    end

    def dropoff_date(reservation)
      pickup_date(reservation) + reservation["length"].to_i.days
    end
  end
end
