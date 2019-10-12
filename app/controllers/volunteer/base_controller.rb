module Volunteer
  class BaseController < ApplicationController
    helper_method :signed_in_via_google?

    private

    def signed_in_via_google?
      session[:email].present?
    end
  end
end