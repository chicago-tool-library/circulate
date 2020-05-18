class AddEndedAtToHolds < ActiveRecord::Migration[6.0]
  def change
    add_column :holds, :ended_at, :datetime
  end
end
