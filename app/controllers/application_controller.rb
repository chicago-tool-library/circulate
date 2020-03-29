class ApplicationController < ActionController::Base
  add_flash_types :success, :error, :warning

  around_action :set_time_zone

  private

  def set_time_zone(&block)
    Time.use_zone("America/Chicago", &block)
  end

  def render_not_found
    render file: "#{Rails.root}/public/404.html", layout: false, status: :not_found
  end
end
