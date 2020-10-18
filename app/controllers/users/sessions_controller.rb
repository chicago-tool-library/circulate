module Users
  class SessionsController < Devise::SessionsController
   def new
     if  request.referer.present? && (request.env["HTTP_REFERER"] && URI.parse(request.env["HTTP_REFERER"])) == request.host
     	self.resource = resource_class.create(sign_in_params)
        store_location_for(resource, request.referer)  
     end
     super
   end
  end
end