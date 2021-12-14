module Admin
  module Reports
    class ShiftsController < BaseController
      include Calendaring

      def index
        @events = Event.volunteer_shifts
      end
    end
  end
end
