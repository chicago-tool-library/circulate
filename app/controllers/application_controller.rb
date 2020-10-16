class ApplicationController < ActionController::Base
  include Pundit

  helper_method :current_member

  add_flash_types :success, :error, :warning

  around_action :set_time_zone

  def current_member
    current_user.member
  end


  private

  def set_time_zone(&block)
    Time.use_zone "America/Chicago" do
      Chronic.time_class = Time.zone
      block.call
    end
  end

  def render_not_found
    render file: "#{Rails.root}/public/404.html", layout: false, status: :not_found
  end

  protected
  def after_sign_in_path_for(user)
    referer = stored_location_for(user)
    if user.admin? || user.staff? 
      if stored_location_for(user).eql? root_path
        admin_dashboard_path
      else
        referer || admin_dashboard_path
      end
    else
      if stored_location_for(user).eql? root_path
        member_loans_path
      else
        referer || member_loans_path
      end
    end
  end
end
