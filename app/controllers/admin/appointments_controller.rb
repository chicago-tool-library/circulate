module Admin
  class AppointmentsController < BaseController
    def index
      @appointments = Appointment.where(starts_at: current_day.beginning_of_day..current_day.end_of_day)
    end

    private

    helper_method def current_day
      @current_day = Date.parse(params[:day] ||= Date.today.to_s)
    end

    helper_method def pervious_day
      current_day - 1.day
    end

    helper_method def next_day
      current_day + 1.day
    end
  end
end
