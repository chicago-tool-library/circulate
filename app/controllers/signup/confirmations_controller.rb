module Signup
  class ConfirmationsController < BaseController
    def show
      activate_step(:complete)
      @payment = session[:payment]
    end
  end
end
