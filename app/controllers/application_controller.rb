require "active_support/testing/time_helpers"

class ApplicationController < ActionController::Base
  include Pundit::Authorization
  include ActiveSupport::Testing::TimeHelpers
  include PageAttributes

  # Move CSRF token storage from its default location in the session (which is
  # destroyed after every browser close) to a long lived cookie in order to
  # prevent InvalidAuthenticityToken errors raised from cached
  # pages being reloaded. For a detailed analysis see:
  #
  #  - The ancient Rails bug tracking this: https://github.com/rails/rails/issues/21948
  #  - The Rails PR with the new feature we're using: https://github.com/rails/rails/pull/44283
  #  - A PR that includes an *excellent* write up and a similar implementation
  #    made before the above feature landed: https://github.com/demarches-simplifiees/demarches-simplifiees.fr/pull/6332
  protect_from_forgery store: NonSessionCookieStore.new(:csrf_token), with: :exception

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

  # Render a turbo-stream response without all the boilerplate
  def render_turbo_response(*args)
    respond_to do |format|
      format.turbo_stream do
        render(*args)
      end
    end
  end
end
