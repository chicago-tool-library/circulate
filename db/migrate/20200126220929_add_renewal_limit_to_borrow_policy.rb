class AddRenewalLimitToBorrowPolicy < ActiveRecord::Migration[6.0]
  def change
    add_column :borrow_policies, :renewal_limit, :integer, default: 0, null: false
  end
end
