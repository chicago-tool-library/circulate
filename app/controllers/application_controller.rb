class ApplicationController < ActionController::Base
  include Pundit

  set_current_tenant_through_filter
  before_action :set_tenant

  helper_method :current_member, :current_library

  add_flash_types :success, :error, :warning

  around_action :set_time_zone

  def current_member
    current_user.member
  end

  def current_library
    @current_library ||= Library.find_by(hostname: request.host.downcase) || Library.first
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

  def set_time_zone(&block)
    Time.use_zone("America/Chicago", &block)
  end

  def after_sign_in_path_for(resource)
    stored_location_for(resource) ||
      if resource.super_admin?
        super_admin_libraries_path
      else
        super
      end
  end

  def render_not_found
    render file: "#{Rails.root}/public/404.html", layout: false, status: :not_found
  end
end
