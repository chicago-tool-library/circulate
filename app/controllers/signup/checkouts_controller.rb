module Signup
  class PaymentsController < BaseController
    before_action :load_member
    before_action :are_payments_enabled?

    def new
    end

    def create
    end
  end
end
