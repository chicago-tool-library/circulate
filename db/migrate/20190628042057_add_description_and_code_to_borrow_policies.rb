class AddDescriptionAndCodeToBorrowPolicies < ActiveRecord::Migration[6.0]
  def change
    add_column :borrow_policies, :code, :string, unique: true
    add_column :borrow_policies, :description, :string
    execute "UPDATE borrow_policies SET code = substr('ABCDEFGHIJKLMNOPQRSTUVWXYZ', id::int, 1);" # standard:disable Rails/ReversibleMigration
    change_column_null :borrow_policies, :code, false
  end
end
