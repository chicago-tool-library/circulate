# frozen_string_literal: true

module Users
  class SessionsController < Devise::SessionsController
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
  end
end
