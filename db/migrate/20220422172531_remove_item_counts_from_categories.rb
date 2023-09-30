# frozen_string_literal: true

class RemoveItemCountsFromCategories < ActiveRecord::Migration[6.1]
  def change
    remove_column :categories, :item_counts, :jsonb, default: {}
  end
end
