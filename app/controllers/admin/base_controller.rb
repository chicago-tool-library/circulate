module Admin
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :require_staff
    before_action :load_requested_renewal_request_count

    layout "admin"

    private

    def require_staff
      unless current_user.roles.include?(:staff)
        redirect_to root_url, warning: "You do not have access to that page."
      end
    end

    def require_admin
      unless current_user.roles.include?(:admin)
        redirect_to root_url, warning: "You do not have access to that page."
      end
    end

    def load_requested_renewal_request_count
      @requested_renewal_request_count = RenewalRequest.requested.count
    end
  end
end
