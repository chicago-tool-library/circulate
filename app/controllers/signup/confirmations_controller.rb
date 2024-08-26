module Signup
  class ConfirmationsController < BaseController
    def show
      activate_step(:complete)
      @amount = Money.new(session[:amount]) if session.key?(:amount)
    end
  end
end
