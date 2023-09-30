# frozen_string_literal: true

module Signup
  class HomeController < BaseController
    before_action :is_membership_enabled?

    def index
      @hide_steps = true
    end
  end
end
