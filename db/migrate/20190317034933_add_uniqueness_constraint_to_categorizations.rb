class AddUniquenessConstraintToCategorizations < ActiveRecord::Migration[6.0]
  def change
    add_index :categorizations, [:item_id, :category_id]
  end
end
