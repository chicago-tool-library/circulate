require "active_support/testing/time_helpers"

module Admin
  class BaseController < ApplicationController
    include ActiveSupport::Testing::TimeHelpers

    before_action :authenticate_user!
    around_action :override_time_in_development, if: -> { Rails.env.development? }

    layout "admin"

    private

    def override_time_in_development(&block)
      if session[:time_override]
        travel_to session[:time_override] do
          yield
        end
      else
        yield
      end
    end
  end
end
