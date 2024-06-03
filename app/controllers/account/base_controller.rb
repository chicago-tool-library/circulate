module Account
  class BaseController < ApplicationController
    before_action :authenticate_user!

    def are_appointments_enabled?
      if !@current_library.allow_appointments?
        render_not_found
      end
    end

    def current_reservation
      @current_reservation ||= Reservation.find_by(
        id: session[:current_reservation_id]
      )
    end
    helper_method :current_reservation
  end
end
