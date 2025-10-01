module Signup
  module Organizations
    class ConfirmEmailController < BaseController
      def show
        activate_step(:confirm_email)
        @email_address = session[:email_address]
      end
    end
  end
end
