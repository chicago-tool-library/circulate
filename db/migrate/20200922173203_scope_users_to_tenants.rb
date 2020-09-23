class ScopeUsersToTenants < ActiveRecord::Migration[6.0]
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
  end
end
