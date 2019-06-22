class AddStatusToItems < ActiveRecord::Migration[6.0]
  def change
    add_column :items, :status, :integer, default: Item.statuses[:active], null: false
  end
end
