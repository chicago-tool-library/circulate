module Volunteer
  class SessionsController < ApplicationController
    include Calendaring

    def create
      if auth_hash
        session[:email] = auth_hash["info"]["email"]
        session[:name] = auth_hash["info"]["name"]

        if session[:event_id]
          return event_signup(session.delete(:event_id))
        end

        redirect_to volunteer_shifts_url, success: "You are logged in."
      else
        redirect_to volunteer_shifts_url, error: "Please try again."
      end
    end
 
    def destroy
      reset_session
      redirect_to volunteer_shifts_url
    end

    private
  
    def auth_hash
      request.env['omniauth.auth']
    end
  end
end