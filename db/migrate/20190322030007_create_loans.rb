# frozen_string_literal: true

class CreateLoans < ActiveRecord::Migration[6.0]
  def change
    create_table :loans do |t|
      t.belongs_to :item, foreign_key: true
      t.belongs_to :member, foreign_key: true
      t.datetime :due_at
      t.datetime :ended_at

      t.timestamps
      t.index :item_id, unique: true, where: "ended_at IS NULL", name: "index_active_loans_on_item_id"
    end
  end
end
