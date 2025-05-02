class DropItemDescription < ActiveRecord::Migration[8.0]
  def change
    remove_column :items, :description, :string
  end
end
