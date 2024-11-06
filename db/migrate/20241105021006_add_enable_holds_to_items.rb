class AddEnableHoldsToItems < ActiveRecord::Migration[7.2]
  def change
    add_column :items, :holds_enabled, :boolean, default: true
  end
end
