module Signup
  class ConfirmationsController < BaseController
    before_action :load_member

    def show
      @adjustment = @member.adjustments.last
    end
  end
end
