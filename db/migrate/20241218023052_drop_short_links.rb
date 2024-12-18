class DropShortLinks < ActiveRecord::Migration[7.2]
  def change
    drop_table :short_links do |t|
      t.string :url, null: false, unique: true
      t.string :slug, null: false, unique: true
      t.integer :views_count, null: false, default: 0

      t.timestamps
    end
  end
end
