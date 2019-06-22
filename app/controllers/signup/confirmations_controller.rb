module Signup
  class ConfirmationsController < BaseController
    def show
      activate_complete_step
    end
  end
end
