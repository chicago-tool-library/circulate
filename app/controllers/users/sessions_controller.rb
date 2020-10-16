module Users
  class SessionsController < Devise::SessionsController
   def new
     if  request.referer.present?
     	self.resource = resource_class.create(sign_in_params)
        store_location_for(resource, request.referer)  
     end
     super
   end
  end
end