# frozen_string_literal: true

class DropMonthlyActivitiesView < ActiveRecord::Migration[6.1]
  def change
    drop_view :monthly_activities, revert_to_version: 1
  end
end
