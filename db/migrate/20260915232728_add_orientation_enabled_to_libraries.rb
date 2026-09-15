class AddOrientationEnabledToLibraries < ActiveRecord::Migration[8.0]
  def change
    add_column :libraries, :orientation_enabled, :boolean, null: false, default: false
  end
end
