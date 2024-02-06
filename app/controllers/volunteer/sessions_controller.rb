module Volunteer
  class SessionsController < BaseController
    include Calendaring

    def create
      if auth_hash
        session[:email] = auth_hash["info"]["email"]
        session[:name] = auth_hash["info"]["name"]

        if session[:event_id]
          @event = Event.volunteer_shifts.find(session.delete(:event_id))
          return event_signup(@event.calendar_event_id)
        end

        redirect_to volunteer_shifts_url, success: "You are logged in.", status: :see_other
      else
        redirect_to volunteer_shifts_url, error: "Please try again.", status: :see_other
      end
    end

    def destroy
      reset_session
      redirect_to volunteer_shifts_url, status: :see_other
    end

    def failure
      raise "failed to authenticate"
    end

    private

    def auth_hash
      request.env["omniauth.auth"]
    end

    def google_calendar_id
      ::Event.volunteer_shift_calendar_id
    end
  end
end
