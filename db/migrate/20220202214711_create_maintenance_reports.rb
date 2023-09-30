# frozen_string_literal: true

class CreateMaintenanceReports < ActiveRecord::Migration[6.1]
  def change
    create_table :maintenance_reports do |t|
      t.text :title
      t.integer :time_spent
      t.belongs_to :item, null: false, foreign_key: true
      t.belongs_to :creator, null: false, foreign_key: { to_table: :users }
      t.enum :current_item_status, enum_type: "item_status"
      t.belongs_to :audit, foreign_key: true

      t.timestamps
    end
  end
end
