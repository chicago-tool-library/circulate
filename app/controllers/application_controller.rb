require "active_support/testing/time_helpers"

class ApplicationController < ActionController::Base
  include ActiveSupport::Testing::TimeHelpers

  add_flash_types :success, :error, :warning

  before_action :authenticate_user!

  around_action :override_time_in_development, if: -> { Rails.env.development? }
  around_action :set_time_zone

  private

  def set_time_zone(&block)
    Time.use_zone("America/Chicago", &block)
  end

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
