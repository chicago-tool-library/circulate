module Admin
  class AppointmentsController < BaseController
    before_action :load_appointment, except: :index
    before_action :are_appointments_enabled?

    def index
      @current_day = Date.parse(params[:day] ||= Time.current.to_date.to_s)
      @appointments = Appointment
        .where(starts_at: @current_day.all_day)
        .chronologically
        .includes(:member, loans: {item: :borrow_policy}, holds: {item: :borrow_policy})

      @pending_appointments = []
      @pulled_appointments = []
      @completed_appointments = []

      @appointments.sort_by { |a| helpers.appointment_sort_key(a) }.each do |appointment|
        if appointment.completed?
          @completed_appointments << appointment
        elsif appointment.pulled_at?
          @pulled_appointments << appointment
        else
          @pending_appointments << appointment
        end
      end

      if FeatureFlags.new_appointments_page_enabled?(params[:new])
        render :index
      else
        render :index, template: "admin/appointments/index_orig"
      end
    end

    def show
    end

    def edit
      load_appointment_slots
    end

    def update
      if @appointment.update(appointment_params)
        redirect_to admin_appointments_path, flash: {success: "Appointment updated."}, status: :see_other
      else
        load_appointment_slots
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      @appointment.destroy
      redirect_to admin_appointments_path, flash: {success: "Appointment cancelled."}, status: :see_other
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
      if @current_day == Date.current
        "Today"
      elsif @current_day == 1.day.from_now.to_date
        "Tomorrow"
      else
        l @current_day, format: :with_weekday
      end
    end

    helper_method def items_available_to_add_to_pickup
      Item.available.includes(:borrow_policy)
    end

    helper_method def items_available_to_add_to_dropoff
      (@appointment.member.loans.checked_out.includes(item: :borrow_policy) - appointment_return_items).map(&:item)
    end

    helper_method def appointment_pickup_items
      @appointment.holds.includes(hold_includes)
    end

    helper_method def appointment_return_items
      @appointment.loans.includes(loan_includes)
    end

    helper_method def checkout_items_quantity_for_appointment
      appointment_pickup_items.active.length
    end

    helper_method def checkin_items_quantity_for_appointment
      appointment_return_items.length
    end

    def item_includes
      [:borrow_policy, :image_attachment]
    end

    def hold_includes
      {item: item_includes}
    end

    def loan_includes
      {item: item_includes}
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
