class ScopeModelsToTenants < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :library_id, :integer
    add_index  :users, :library_id
    add_index  :users, [:email, :library_id]
    add_index  :users, [:member_id, :library_id]
    add_index  :users, [:reset_password_token, :library_id]
    add_index  :users, [:unlock_token, :library_id]

    add_column :members, :library_id, :integer
    add_index  :members, :library_id
    add_index  :members, [:number, :library_id]

    add_column :memberships, :library_id, :integer

    add_column :items, :library_id, :integer
    add_index  :items, :library_id
    add_index  :items, [:borrow_policy_id, :library_id]
    add_index  :items, [:number, :library_id], unique: true

    add_column :loans, :library_id, :integer
    add_index  :loans, :library_id
    add_index  :loans, [:ended_at, :library_id]
    add_index  :loans, [:initial_loan_id, :renewal_count, :library_id], unique: true
    add_index  :loans, [:initial_loan_id, :library_id]
    add_index  :loans, [:item_id, :library_id], name: "index_active_numbered_loans_on_item_id_and_library_id", unique: true, where: "((ended_at IS NULL) AND (uniquely_numbered = true))"
    add_index  :loans, [:item_id, :library_id]
    add_index  :loans, [:member_id, :library_id]

    add_column :documents, :library_id, :integer
    add_index :documents, [:library_id, :code]

    add_column :borrow_policies, :library_id, :integer
    add_index :borrow_policies, [:library_id, :name], unique: true

    add_column :gift_memberships, :library_id, :integer
    add_index :gift_memberships, [:library_id, :code], unique: true

    add_column :notifications, :library_id, :integer
    add_index :notifications, :library_id

    add_column :holds, :library_id, :integer
    add_index :holds, :library_id

    add_column :categories, :library_id, :integer
    add_index :categories, [:library_id, :name], unique: true
    add_index :categories, [:library_id, :slug], unique: true

    add_column :events, :library_id, :integer
    add_index :events, :library_id

    add_column :short_links, :library_id, :integer
    add_index :short_links, [:library_id, :slug]
  end
end
