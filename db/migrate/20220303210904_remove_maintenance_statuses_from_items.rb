class RemoveMaintenanceStatusesFromItems < ActiveRecord::Migration[6.1]
  def change
    # standard:disable Rails/ReversibleMigration
    execute "UPDATE items SET status = 'maintenance' WHERE status = 'maintenance_parts' OR status = 'maintenance_repairing'"
    execute "ALTER TYPE item_status RENAME TO item_status_old"
    create_enum :item_status, ["pending", "active", "maintenance", "retired"]
    execute <<~SQL
      ALTER TABLE items
        ALTER COLUMN status DROP DEFAULT,
        ALTER COLUMN status TYPE item_status USING (status::text::item_status),
        ALTER COLUMN status SET DEFAULT 'active'
    SQL
    execute "DROP TYPE item_status_old"
    # standard:enable Rails/ReversibleMigration
  end
end
