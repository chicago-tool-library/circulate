# frozen_string_literal: true

class CreateTickets < ActiveRecord::Migration[6.1]
  def change
    create_table :tickets do |t|
      t.string :title, null: false
      t.references :item, null: false, foreign_key: true
      t.enum :status, enum_type: "ticket_status", null: false, default: "assess"
      t.belongs_to :creator, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
