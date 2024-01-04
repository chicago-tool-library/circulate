module Admin
  class AppointmentsController < BaseController
    before_action :load_appointment, except: :index
    before_action :are_appointments_enabled?

    def index
      @current_day = Date.parse(params[:day] ||= Time.current.to_date.to_s)
      @appointments = Appointment
        .where(starts_at: @current_day.beginning_of_day..@current_day.end_of_day)
        .chronologically
        .includes(:member, loans: {item: :borrow_policy}, holds: {item: :borrow_policy})

      @pending_appointments = []
      @completed_appointments = []
      sort_by_member_and_time(@appointments).each_with_index do |appointment, index|
        if appointment.completed?
          @completed_appointments << [appointment, index]
        else
          @pending_appointments << [appointment, index]
        end
      end
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

    def sort_by_member_and_time(appointments)
      appointments
        .group_by { |a| a.member }
        .map { |member, appointments| [appointments.map(&:starts_at).min, appointments] }
        .sort_by { |first_time, appointments| [first_time, helpers.preferred_or_default_name(appointments.first.member)] }
        .flat_map { |_, appointments| appointments.sort_by(&:created_at) }
    end

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
      if @current_day == Date.current
        "Today"
      elsif @current_day == 1.day.from_now.to_date
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
