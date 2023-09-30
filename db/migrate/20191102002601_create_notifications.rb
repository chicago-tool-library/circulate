# frozen_string_literal: true

class CreateNotifications < ActiveRecord::Migration[6.0]
  def change
    create_enum :notification_status, ["pending", "sent", "bounced", "error"]

    create_table :notifications do |t|
      t.string :address, null: false
      t.string :action, null: false
      t.references :member, null: false, foreign_key: true
      t.uuid :uuid, null: false
      t.enum :status, enum_type: :notification_status, default: "pending", null: false
      t.string :subject, null: false

      t.timestamps
    end

    add_index :notifications, :uuid
  end
end
