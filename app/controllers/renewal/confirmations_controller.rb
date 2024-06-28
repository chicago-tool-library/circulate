module Renewal
  class ConfirmationsController < BaseController
    def show
      activate_step(:complete)
      @payment = session[:payment]
    end
  end
end
