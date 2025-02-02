class AdjustItemPoolFields < ActiveRecord::Migration[7.2]
  def change
    remove_column :item_pools, :brand, :string
    remove_column :item_pools, :model, :string
    remove_column :item_pools, :size, :string
    remove_column :item_pools, :strength, :string
    remove_column :item_pools, :power_source, :enum, enum_type: "power_source"
    remove_column :item_pools, :location_area, :string
    remove_column :item_pools, :location_shelf, :string
    remove_column :item_pools, :purchase_link, :string
    remove_column :item_pools, :url, :string
    add_column :reservable_items, :size, :string
    add_column :reservable_items, :strength, :string
    add_column :reservable_items, :power_source, :enum, enum_type: "power_source"
    add_column :reservable_items, :location_area, :string
    add_column :reservable_items, :location_shelf, :string
    add_column :reservable_items, :purchase_link, :string
    add_column :reservable_items, :url, :string
    remove_column :reservable_items, :name, :string
    add_column :item_pools, :checkout_notice, :string
  end
end
