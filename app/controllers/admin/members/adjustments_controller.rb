# frozen_string_literal: true

module Admin
  module Members
    class AdjustmentsController < BaseController
      def index
        @adjustments = @member.adjustments.order(created_at: :desc)
      end
    end
  end
end
