class AddCounterCacheToCategory < ActiveRecord::Migration[6.0]
  def change
    add_column :categories, :categorizations_count, :integer, default: 0, null: false
  end
end
