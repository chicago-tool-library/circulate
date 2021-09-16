module Admin
  module Reports
    class MoneyController < BaseController
      def index
        @monthly_adjustments = MonthlyAdjustment.chronologically.all
      end
    end
  end
end
