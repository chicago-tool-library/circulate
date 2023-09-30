# frozen_string_literal: true

class RemoveUserUniqueness < ActiveRecord::Migration[6.0]
  def change
    remove_index :users, column: :email, name: "index_users_on_email", unique: true
    add_index :users, :email
  end
end
