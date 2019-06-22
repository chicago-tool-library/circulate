class ApplicationController < ActionController::Base
  add_flash_types :success, :error, :warning

  around_action :set_time_zone

  private

  def set_time_zone(&block)
    Time.use_zone("America/Chicago", &block)
  end
end
