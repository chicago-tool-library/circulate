class AddStrengthToItems < ActiveRecord::Migration[6.0]
  def change
    add_column :items, :strength, :string
  end
end
