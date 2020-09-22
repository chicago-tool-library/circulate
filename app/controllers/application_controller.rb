class ApplicationController < ActionController::Base
  include Pundit

  helper_method :current_member

  add_flash_types :success, :error, :warning

  around_action :set_time_zone

  set_current_tenant_by_subdomain(:library, :subdomain)

  def current_member
    current_user.member
  end

  private

  def set_time_zone(&block)
    Time.use_zone("America/Chicago", &block)
  end

  def render_not_found
    render file: "#{Rails.root}/public/404.html", layout: false, status: :not_found
  end
end
