require "active_support/testing/time_helpers"

class ApplicationController < ActionController::Base
  include Pundit
  include ActiveSupport::Testing::TimeHelpers
  include PageAttributes

  set_current_tenant_through_filter
  before_action :set_tenant

  helper_method :current_member, :current_library

  add_flash_types :success, :error, :warning

  around_action :set_time_zone
  around_action :override_time_in_development, if: -> { Rails.env.development? }

  def are_appointments_enabled?
    if !@current_library.allow_appointments?
      render_not_found
    end
  end

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
    Time.use_zone "America/Chicago" do
      Chronic.time_class = Time.zone
      block.call
    end
  end

  def render_not_found
    render "errors/show", status: :not_found
  end

  def after_sign_in_path_for(user)
    return super_admin_libraries_path if user.super_admin?

    referer = stored_location_for(user)
    default_path = (user.admin? || user.staff?) ? admin_dashboard_path : account_home_path
    if referer.eql? root_path
      default_path
    else
      referer || default_path
    end
  end
end
