# frozen_string_literal: true

class CreateShortLinks < ActiveRecord::Migration[6.0]
  def change
    create_table :short_links do |t|
      t.string :url, null: false, unique: true
      t.string :slug, null: false, unique: true
      t.integer :views_count, null: false, default: 0

      t.timestamps
    end
  end
end
