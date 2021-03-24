module Admin
  class AppointmentsController < BaseController
    def index
      @current_day = Date.parse(params[:day] ||= Time.current.to_date.to_s)
      @appointments = Appointment.where(starts_at: @current_day.beginning_of_day..@current_day.end_of_day).chronologically
    end

    def show
    end

    def edit
      load_appointment_slots
    end

    def update
      if current_appointment.update(appointment_params)
        redirect_to admin_appointments_path, flash: {success: "Appointment updated."}
      else
        load_appointment_slots
        render :edit
      end
    end

    def destroy
      current_appointment.destroy
      redirect_to admin_appointments_path, flash: {success: "Appointment cancelled."}
    end

    private

    helper_method def previous_day
      @current_day - 1.day
    end

    helper_method def next_day
      @current_day + 1.day
    end

    helper_method def current_day_label
      if @current_day == Date.today
        "Today"
      elsif @current_day == Date.tomorrow
        "Tomorrow"
      else
        l @current_day, format: :with_weekday
      end
    end

    helper_method def current_appointment
      Appointment.find(params[:id])
    end

    helper_method def items_available_to_add_to_pickup
      Item.available.eager_load(:borrow_policy)
    end

    helper_method def items_available_to_add_to_dropoff
      (current_appointment.member.loans.checked_out - appointment_return_items).map(&:item)
    end

    helper_method def appointment_pickup_items
      current_appointment.holds
    end

    helper_method def appointment_return_items
      current_appointment.loans
    end

    helper_method def checkout_items_quantity_for_appointment
      appointment_pickup_items.active.length
    end

    helper_method def checkin_items_quantity_for_appointment
      appointment_return_items.length
    end

    helper_method def appointment_time_range_string
      "#{current_appointment.starts_at}..#{current_appointment.ends_at}"
    end

    def appointment_params
      update_params = params.require(:appointment).permit(:time_range_string)
      appointment_times = update_params[:time_range_string].split("..")
      update_params[:starts_at] = DateTime.parse appointment_times[0]
      update_params[:ends_at] = DateTime.parse appointment_times[1]
      update_params
    end

    def load_appointment_slots
      events = Event.appointment_slots.upcoming
      @appointment_slots = events.group_by { |event| event.start.to_date }.map { |date, events|
        times = events.map { |event| [event.times, event.start..event.finish] }
        [date.strftime("%A, %B %-d, %Y"), times]
      }
    end
  end
end
