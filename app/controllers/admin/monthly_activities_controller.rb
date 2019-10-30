module Admin
  class MonthlyActivitiesController < BaseController
    def index
      @monthly_activities = MonthlyActivity.all
    end
  end
end
