class CreateItemPools < ActiveRecord::Migration[7.1]
  def change
    create_table :item_pools do |t|
      t.references :creator, null: false, foreign_key: {to_table: "users"}
      t.string :name

      t.timestamps
    end
  end
end
