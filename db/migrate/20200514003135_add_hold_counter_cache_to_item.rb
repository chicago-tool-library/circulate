# frozen_string_literal: true

class AddHoldCounterCacheToItem < ActiveRecord::Migration[6.0]
  def change
    add_column :items, :holds_count, :integer, default: 0, null: false
  end
end
