# frozen_string_literal: true

class UpdateMonthlyAdjustmentsToVersion2 < ActiveRecord::Migration[6.1]
  def change
    update_view :monthly_adjustments, version: 2, revert_to_version: 1
  end
end
