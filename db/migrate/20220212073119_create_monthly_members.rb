class CreateMonthlyMembers < ActiveRecord::Migration[6.1]
  def change
    create_view :monthly_members
  end
end
