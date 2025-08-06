module Signup
  module Organizations
    class PoliciesController < BaseController
      def show
        activate_step(:policies)
      end
    end
  end
end
