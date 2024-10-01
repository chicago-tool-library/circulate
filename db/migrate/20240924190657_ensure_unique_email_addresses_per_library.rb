class EnsureUniqueEmailAddressesPerLibrary < ActiveRecord::Migration[7.2]
  def up
    remove_index :users, %i[email library_id]
    execute "CREATE UNIQUE INDEX index_users_on_lowercase_email_and_library_id ON users USING btree (lower(email), library_id);"
  end

  def down
    execute "DROP INDEX index_users_on_lowercase_email_and_library_id;"
    add_index :users, %i[email library_id]
  end
end
