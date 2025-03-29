class AddAccessoriesToItems < ActiveRecord::Migration[8.0]
  def change
    add_column :items, :accessories, :string, array: true, default: [], null: false
  end
end
