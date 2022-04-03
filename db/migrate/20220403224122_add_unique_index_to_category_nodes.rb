class AddUniqueIndexToCategoryNodes < ActiveRecord::Migration[6.1]
  def change
    add_index :category_nodes, :id, unique: true
  end
end
