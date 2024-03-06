class AddUnnumberedCountToItemPools < ActiveRecord::Migration[7.1]
  def change
    add_column :item_pools, :unnumbered_count, :integer
  end
end
