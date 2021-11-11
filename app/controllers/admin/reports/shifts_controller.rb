module Admin
  module Reports
    class ShiftsController < BaseController
      include Calendaring

      def index
        load_upcoming_events
      end
    end
  end
end
