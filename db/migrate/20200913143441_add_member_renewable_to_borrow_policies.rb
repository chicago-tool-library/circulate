class AddMemberRenewableToBorrowPolicies < ActiveRecord::Migration[6.0]
  def change
    add_column :borrow_policies, :member_renewable, :boolean, null: false, default: false
  end
end
