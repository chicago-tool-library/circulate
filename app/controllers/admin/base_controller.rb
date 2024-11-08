module Admin
  class BaseController < ApplicationController
    include ActionView::RecordIdentifier

    before_action :authenticate_user!
    before_action :require_staff
    before_action :load_requested_renewal_request_count

    layout :custom_layout

    private

    def custom_layout
      return "turbo_rails/frame" if turbo_frame_request?

      "admin"
    end

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

    def are_appointments_enabled?
      if !@current_library.allow_appointments?
        render_not_found
      end
    end

    def flash_highlight(id_or_object)
      identifier = if String === id_or_object
        id_or_object
      else
        dom_id(id_or_object)
      end
      flash[:highlight] ||= []
      flash[:highlight] << identifier
    end
  end
end
