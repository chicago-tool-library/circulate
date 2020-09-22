class ApplicationController < ActionController::Base
  include Pundit

  set_current_tenant_through_filter
  before_action :set_tenant

  helper_method :current_member

  add_flash_types :success, :error, :warning

  around_action :set_time_zone

  def current_member
    current_user.member
  end

  private

  def set_tenant
    if current_library
      set_current_tenant current_library
    else
      Rails.logger.debug "No Library found for the provided hostname"
      render_not_found
    end
  end

  def current_library
    @current_library ||= Library.find_by(hostname: request.host.downcase) || Library.first
  end

  def set_time_zone(&block)
    Time.use_zone("America/Chicago", &block)
  end

  def render_not_found
    render file: "#{Rails.root}/public/404.html", layout: false, status: :not_found
  end
end
