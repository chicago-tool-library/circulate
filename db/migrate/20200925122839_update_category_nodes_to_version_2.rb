class UpdateCategoryNodesToVersion2 < ActiveRecord::Migration[6.0]
  def change
    update_view :category_nodes,
      version: 2,
      revert_to_version: 1,
      materialized: true
  end
end
