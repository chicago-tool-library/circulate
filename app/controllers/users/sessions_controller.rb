module Users
  class SessionsController < Devise::SessionsController
    # Skip CSRF to stop InvalidAuthenticityToken errors that hurt real users
    # (mostly mobile Safari after ITP evicts the csrf_token cookie). Login is
    # public, login-CSRF is low-impact, and Devise rotates the session on
    # successful sign-in. See application_controller.rb for prior chapters.
    skip_before_action :verify_authenticity_token, only: :create

    def new
      if request.referer.present?
        referer = URI.parse(request.referer)
        if referer.host == request.host
          store_location_for(:user, request.referer)
        end
      end
    rescue URI::InvalidURIError
      # bad URI, ignore
    ensure
      super
    end

    def create
      super
    end
  end
end
