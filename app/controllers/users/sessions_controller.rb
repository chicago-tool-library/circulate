module Users
  class SessionsController < Devise::SessionsController
    def new
      if request.referer.present?
        referer = URI.parse(request.referer)
        if referer.host == request.host
          self.resource = resource_class.create(sign_in_params)
          store_location_for(resource, request.referer)
        end
      end
    rescue URI::InvalidURIError
      # bad URI, ignore
    ensure
      super
    end
  end
end
