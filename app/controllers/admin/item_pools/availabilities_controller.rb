module Admin
  module ItemPools
    class AvailabilitiesController < BaseController
      def show
        reserved_by_date = @item_pool.reserved_by_date(Time.current.beginning_of_month, Time.current.end_of_month)
        @month_calendar = GroupLending::MonthCalendar.new(reserved_by_date)
      end
    end
  end
end
