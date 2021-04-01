module Admin
  class AppointmentsController < BaseController
    before_action :load_appointment, except: :index

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
      if @appointment.update(appointment_params)
        redirect_to admin_appointments_path, flash: {success: "Appointment updated."}
      else
        load_appointment_slots
        render :edit
      end
    end

    def destroy
      @appointment.destroy
      redirect_to admin_appointments_path, flash: {success: "Appointment cancelled."}
    end

    private

    def load_appointment
      @appointment = Appointment.find(params[:id])
    end

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

    helper_method def items_available_to_add_to_pickup
      Item.available.eager_load(:borrow_policy)
    end

    helper_method def items_available_to_add_to_dropoff
      (@appointment.member.loans.checked_out - appointment_return_items).map(&:item)
    end

    helper_method def appointment_pickup_items
      @appointment.holds
    end

    helper_method def appointment_return_items
      @appointment.loans
    end

    helper_method def checkout_items_quantity_for_appointment
      appointment_pickup_items.active.length
    end

    helper_method def checkin_items_quantity_for_appointment
      appointment_return_items.length
    end

    def appointment_params
      params.require(:appointment).permit(:time_range_string)
    end

    def load_appointment_slots
      events = Event.appointment_slots.upcoming
      @appointment_slots = events.group_by { |event| event.start.to_date }.map { |date, events|
        times = events.map { |event| [helpers.format_appointment_times(event.start, event.finish), event.start..event.finish] }
        [date.strftime("%A, %B %-d, %Y"), times]
      }
    end
  end
end
