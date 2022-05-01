class UpdateCategoryNodesToVersion3 < ActiveRecord::Migration[6.1]
  def change
    update_view :category_nodes,
      version: 3,
      revert_to_version: 2,
      materialized: true
  end
end
