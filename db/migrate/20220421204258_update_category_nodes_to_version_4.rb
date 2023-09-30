# frozen_string_literal: true

class UpdateCategoryNodesToVersion4 < ActiveRecord::Migration[6.1]
  def change
    update_view :category_nodes, version: 4, revert_to_version: 3, materialized: true
  end
end
