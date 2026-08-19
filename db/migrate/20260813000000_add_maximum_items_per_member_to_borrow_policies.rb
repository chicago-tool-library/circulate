class AddMaximumItemsPerMemberToBorrowPolicies < ActiveRecord::Migration[8.0]
  def up
    add_column :borrow_policies, :maximum_items_per_member, :integer, null: false, default: 0

    execute <<~SQL
      UPDATE borrow_policies
      SET maximum_items_per_member = 2
      WHERE code = 'C'
    SQL
  end

  def down
    remove_column :borrow_policies, :maximum_items_per_member
  end
end
