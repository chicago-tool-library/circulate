class RemoveForeignKeyFromCategorizations < ActiveRecord::Migration[7.1]
  def change
    remove_foreign_key :categorizations, :items, column: "categorized_id"
  end
end
