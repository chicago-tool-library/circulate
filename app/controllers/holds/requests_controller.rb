module Holds
  class RequestsController < BaseController
    def destroy
      session[:requested_item_ids] = []
      redirect_to holds_url
    end
  end
end
