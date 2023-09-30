# frozen_string_literal: true

module Renewal
  class HomeController < BaseController
    def index
      @hide_steps = true
    end
  end
end
