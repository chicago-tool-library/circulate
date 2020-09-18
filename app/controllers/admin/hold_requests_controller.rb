module Admin
  class HoldRequestsController < BaseController
    def index
      @hold_requests = HoldRequest.all
    end
  end
end
