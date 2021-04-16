class AddStartedAtToHolds < ActiveRecord::Migration[6.0]
  def change
    add_column :holds, :started_at, :timestamp
  end
end
