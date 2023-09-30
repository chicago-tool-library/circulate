# frozen_string_literal: true

class AddMyTurnItemTypeToItems < ActiveRecord::Migration[6.1]
  def change
    add_column :items, :myturn_item_type, :string
  end
end
