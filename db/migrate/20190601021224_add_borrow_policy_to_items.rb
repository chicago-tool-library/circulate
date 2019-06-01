class AddBorrowPolicyToItems < ActiveRecord::Migration[6.0]
  def change
    add_reference :items, :borrow_policy, null: false
  end
end
