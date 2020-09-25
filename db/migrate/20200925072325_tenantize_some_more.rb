class TenantizeSomeMore < ActiveRecord::Migration[6.0]
  def change
    add_column :documents, :library_id, :integer
    add_index :documents, [:library_id, :code]

    add_column :borrow_policies, :library_id, :integer
    add_index :borrow_policies, [:library_id, :name], unique: true

    add_column :hold_requests, :library_id, :integer
    add_index :hold_requests, :library_id

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
