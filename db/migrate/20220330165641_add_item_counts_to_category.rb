# frozen_string_literal: true

class AddItemCountsToCategory < ActiveRecord::Migration[6.1]
  def change
    add_column :categories, :item_counts, :jsonb, default: {}
  end
end
