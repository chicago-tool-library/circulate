class AddAttributesToItemPools < ActiveRecord::Migration[7.1]
  def change
    add_column :item_pools, :description, :text
    add_column :item_pools, :size, :text
    add_column :item_pools, :brand, :text
    add_column :item_pools, :model, :text
    add_column :item_pools, :strength, :text
    add_column :item_pools, :other_names, :text
    add_column :item_pools, :power_source, :enum, enum_type: "power_source"
    add_column :item_pools, :location_area, :text
    add_column :item_pools, :location_shelf, :text
    add_column :item_pools, :plain_text_description, :text
    add_column :item_pools, :url, :text
    add_column :item_pools, :purchase_link, :text
  end
end
