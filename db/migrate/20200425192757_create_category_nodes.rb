# frozen_string_literal: true

class CreateCategoryNodes < ActiveRecord::Migration[6.0]
  def change
    create_view :category_nodes, materialized: true
  end
end
