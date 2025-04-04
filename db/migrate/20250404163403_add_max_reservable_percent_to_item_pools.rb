class AddMaxReservablePercentToItemPools < ActiveRecord::Migration[8.0]
  def change
    add_column :item_pools, :max_reservable_percent, :decimal, precision: 2, scale: 2
  end
end
