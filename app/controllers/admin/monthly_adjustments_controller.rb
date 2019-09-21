module Admin
  class MonthlyAdjustmentsController < BaseController
    def index
      @monthly_adjustments = MonthlyAdjustment.chronologically.all
    end
  end
end