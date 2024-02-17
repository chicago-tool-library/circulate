class AddReservableItemsCountToItemPools < ActiveRecord::Migration[7.1]
  def change
    add_column :item_pools, :reservable_items_count, :integer, default: 0, null: false
  end
end
