class RenameCategoriesToTags < ActiveRecord::Migration[6.0]
  def change
    rename_table :categories, :tags
    rename_column :tags, :categorizations_count, :taggings_count

    rename_table :categorizations, :taggings
    rename_column :taggings, :category_id, :tag_id
  end
end
