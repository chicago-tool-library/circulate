# frozen_string_literal: true

class CreateLibraries < ActiveRecord::Migration[6.0]
  def change
    create_table :libraries do |t|
      t.string :name, null: false
      t.string :hostname, null: false, index: { unique: true }
      t.string :member_postal_code_pattern, limit: 100, null: true, default: nil
      t.string :city, null: false
      t.string :email, null: false
      t.text :address

      t.timestamps
    end
  end
end
