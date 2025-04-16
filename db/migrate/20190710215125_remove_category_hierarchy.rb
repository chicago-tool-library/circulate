class RemoveCategoryHierarchy < ActiveRecord::Migration[6.0]
  def change
    remove_column :categories, :ancestry # standard:disable Rails/ReversibleMigration
  end
end
