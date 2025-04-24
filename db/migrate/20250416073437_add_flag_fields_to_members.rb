class AddFlagFieldsToMembers < ActiveRecord::Migration[8.0]
  def change
    add_column :members, :flagged, :boolean
  end
end
