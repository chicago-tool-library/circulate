class ChangeEventAttendeesToJsonb < ActiveRecord::Migration[6.1]
  def change
    remove_column :events, :attendees # standard:disable Rails/ReversibleMigration
    add_column :events, :attendees, :jsonb
  end
end
