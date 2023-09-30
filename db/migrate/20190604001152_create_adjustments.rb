# frozen_string_literal: true

class CreateAdjustments < ActiveRecord::Migration[6.0]
  def change
    create_table :adjustments do |t|
      t.references :adjustable, polymorphic: true, null: false
      t.integer :amount_cents, null: false, default: 0
      t.string :amount_currency, null: false, default: "USD"
      t.references :member, foreign_key: true, null: false
      t.integer :kind, null: false

      t.timestamps
    end
  end
end
