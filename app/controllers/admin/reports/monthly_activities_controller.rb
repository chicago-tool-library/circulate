module Admin
  module Reports
    class MonthlyActivitiesController < BaseController
     def index
        @monthly_activities = MonthlyActivity.all
      end
    end
  end
end
