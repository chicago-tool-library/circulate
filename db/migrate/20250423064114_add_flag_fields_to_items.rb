class AddFlagFieldsToItems < ActiveRecord::Migration[8.0]
  def change
    add_column :items, :flagged, :boolean
  end
end
