class AddNumberToItems < ActiveRecord::Migration[6.0]
  def change
    add_column :items, :number, :integer, null: false, unique: true
  end
end
