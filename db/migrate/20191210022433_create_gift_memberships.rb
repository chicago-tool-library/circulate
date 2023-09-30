# frozen_string_literal: true

class CreateGiftMemberships < ActiveRecord::Migration[6.0]
  def change
    create_table :gift_memberships do |t|
      t.string :purchaser_email, null: false
      t.string :purchaser_name, null: false
      t.integer :amount_cents, null: false
      t.string :code, null: false, unique: true
      t.references :membership, foreign_key: true

      t.timestamps
    end
  end
end
