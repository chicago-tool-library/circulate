class AddHostnameToLibraries < ActiveRecord::Migration[6.0]
  def change
    add_column :libraries, :hostname, :string
    add_index :libraries, :hostname, unique: true
  end
end
