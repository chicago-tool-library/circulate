class CreateMonthlyLoans < ActiveRecord::Migration[6.1]
  def change
    create_view :monthly_loans
  end
end
