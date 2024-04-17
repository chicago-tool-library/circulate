class CategoryNode < ApplicationRecord
  self.primary_key = :id

  has_many :categorizations, ->(cn) { rewhere(category_id: cn.tree_ids) },
    foreign_key: "category_id"
  has_many :categorizeds, through: :categorizations
  has_many :items, through: :categorizations, source: "categorized", source_type: "Item"
  has_many :item_pools, through: :categorizations, source: "categorized", source_type: "ItemPool"

  acts_as_tenant :library

  scope :with_items, -> { where("(tree_item_counts->>'active')::int > 0") }
  scope :with_item_pools, -> { where("(tree_reservable_item_counts->>'active')::int > 0") }
  scope :sorted, -> { order("sort_name ASC") }

  def full_name
    path_names.join("  ")
  end

  def visible_items_count
    tree_item_counts.values_at("active", "maintenance").sum
  end

  def visible_reservable_items_count
    tree_reservable_item_counts.values_at("active", "maintenance").sum
  end

  # used for dom_class and other view-level helpers
  def model_name
    ActiveModel::Name.new(Category)
  end

  def self.refresh
    Scenic.database.refresh_materialized_view(table_name, concurrently: true, cascade: false)
  end
end
