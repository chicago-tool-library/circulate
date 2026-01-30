module Account
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :require_member

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

    private

    def require_member
      return if current_member.present?

      Appsignal.report_error(RuntimeError.new("User without member record accessed account area")) do |transaction|
        transaction.set_custom_data(
          user_id: current_user.id,
          user_email: current_user.email,
          user_role: current_user.role
        )
      end

      redirect_to root_path, alert: "There's a problem with your account. Please contact the library for assistance."
    end
  end
end
