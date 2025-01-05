class CreateMonthlyRenewals < ActiveRecord::Migration[7.2]
  def change
    create_view :monthly_renewals
  end
end
