# frozen_string_literal: true

class CreateTicketUpdates < ActiveRecord::Migration[6.1]
  def change
    create_table :ticket_updates do |t|
      t.integer :time_spent
      t.belongs_to :ticket, null: false, foreign_key: true
      t.belongs_to :creator, null: false, foreign_key: { to_table: :users }
      t.belongs_to :audit, foreign_key: true

      t.timestamps
    end
  end
end
