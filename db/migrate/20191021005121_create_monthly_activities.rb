class CreateMonthlyActivities < ActiveRecord::Migration[6.0]
  def change
    create_view :monthly_activities
  end
end
