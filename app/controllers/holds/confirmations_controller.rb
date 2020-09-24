module Holds
  class ConfirmationsController < BaseController
    def show
      @hold_request = GlobalID::Locator.locate_signed(params[:id])
      unless @hold_request
        redirect_to holds_url, error: "That hold request was not found."
      end
      activate_step(:complete)
    end
  end
end
