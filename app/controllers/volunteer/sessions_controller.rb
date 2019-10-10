module Volunteer
  class SessionsController < ApplicationController
    def create
      if auth_hash
        session[:email] = auth_hash["info"]["email"]
        session[:name] = auth_hash["info"]["name"]
        redirect_to volunteer_shifts_path
      else
        redirect_to volunteer_shifts_path, error: "Please try again."
      end
    end
 
    def destroy
      reset_session
      redirect_to volunteer_shifts_path
    end

    private
  
    def auth_hash
      request.env['omniauth.auth']
    end
  end
end