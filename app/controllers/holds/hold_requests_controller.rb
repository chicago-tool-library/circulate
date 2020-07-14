module Holds
  class HoldRequestsController < BaseController
    def new
      activate_step(:submit)
      @hold_request = HoldRequest.new
    end

    def create
      @hold_request = HoldRequest.new(hold_request_params)
      if @hold_request.save
        redirect_to holds_path
      else
        activate_step(:submit)
        render :new, status: 422
      end
    end

    private

    def hold_request_params
      params.require(:hold_request).permit(:notes, :email, :postal_code)
    end
  end
end
