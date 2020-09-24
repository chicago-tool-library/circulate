class ScopeItemsLoansToTenants < ActiveRecord::Migration[6.0]
  def change
    add_column :items, :library_id, :integer
    add_index  :items, :library_id
    add_index  :items, [:borrow_policy_id, :library_id]

    add_column :loans, :library_id, :integer
    add_index  :loans, :library_id
    add_index  :loans, [:ended_at, :library_id]
    add_index  :loans, [:initial_loan_id, :renewal_count, :library_id], unique: true
    add_index  :loans, [:initial_loan_id, :library_id]
    add_index  :loans, [:item_id, :library_id], name: "index_active_numbered_loans_on_item_id_and_library_id", unique: true, where: "((ended_at IS NULL) AND (uniquely_numbered = true))"
    add_index  :loans, [:item_id, :library_id]
    add_index  :loans, [:member_id, :library_id]
  end
end
