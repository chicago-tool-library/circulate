class AddUniquelyNumberedToItemPools < ActiveRecord::Migration[7.1]
  def change
    add_column :item_pools, :uniquely_numbered, :boolean, default: true, null: false
  end
end
