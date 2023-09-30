# frozen_string_literal: true

class AddExpiresAtToHolds < ActiveRecord::Migration[6.1]
  def change
    add_column :holds, :expires_at, :datetime
  end
end
