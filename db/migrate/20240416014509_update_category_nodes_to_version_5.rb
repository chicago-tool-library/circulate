class UpdateCategoryNodesToVersion5 < ActiveRecord::Migration[7.1]
  def change
    update_view :category_nodes, version: 5, revert_to_version: 4, materialized: true
  end
end
