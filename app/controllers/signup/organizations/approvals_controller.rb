module Signup
  module Organizations
    class ApprovalsController < BaseController
      def show
        activate_step(:approval)
      end
    end
  end
end
