# frozen_string_literal: true

module Volunteer
  class BaseController < ApplicationController
    before_action :redirect_to_teamup
    helper_method :signed_in_via_google?

    private
      def signed_in_via_google?
        session[:email].present?
      end

      def redirect_to_teamup
        redirect_to "https://teamup.com/ksnp8rrsst1ow8nvwn"
        false
      end
  end
end
