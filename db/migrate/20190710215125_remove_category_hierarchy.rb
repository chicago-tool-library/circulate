# frozen_string_literal: true

class RemoveCategoryHierarchy < ActiveRecord::Migration[6.0]
  def change
    remove_column :categories, :ancestry
  end
end
