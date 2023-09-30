# frozen_string_literal: true

class AddItemLocationFields < ActiveRecord::Migration[6.1]
  def change
    add_column :items, :location_area, :text
    add_column :items, :location_shelf, :text
  end
end
