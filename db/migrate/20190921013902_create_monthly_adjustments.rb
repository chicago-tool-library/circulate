class CreateMonthlyAdjustments < ActiveRecord::Migration[6.0]
  def change
    create_view :monthly_adjustments
  end
end
