class RelaxNotificationsSchemaForSms < ActiveRecord::Migration[7.1]
  def change
    # Twilio SIDs are not UUIDs
    # Since we're changing column types we need to reindex
    remove_index :notifications, :uuid
    change_column :notifications, :uuid, :string, null: false # standard:disable Rails/ReversibleMigration
    add_index :notifications, :uuid

    # Twilio has more statuses, so we're backing out of the status enum for now
    change_column :notifications, :status, :string, default: "pending", null: false # standard:disable Rails/ReversibleMigration

    # PG enum for notification status no longer used
    drop_enum :notification_status
  end
end
