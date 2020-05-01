class RenameTagsToCategories < ActiveRecord::Migration[6.0]
  def change
    rename_table :tags, :categories
    rename_column :categories, :taggings_count, :categorizations_count

    rename_table :taggings, :categorizations
    rename_column :categorizations, :tag_id, :category_id
  end
end
