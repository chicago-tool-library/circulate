# frozen_string_literal: true

module Account
  class BaseController < ApplicationController
    before_action :authenticate_user!

    def are_appointments_enabled?
      if !@current_library.allow_appointments?
        render_not_found
      end
    end
  end
end
