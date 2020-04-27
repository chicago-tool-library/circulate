class CategoryNode < ApplicationRecord
  self.primary_key = :id

  has_many :categorizations, ->(cn) { rewhere(category_id: cn.tree_ids) },
    foreign_key: "category_id"
  has_many :items, through: :categorizations

  def self.refresh
    Scenic.database.refresh_materialized_view(table_name, concurrently: false, cascade: false)
  end

  # used for dom_class and other view-level helpers
  def model_name
    ActiveModel::Name.new(Category)
  end
end
