class Categorization < ApplicationRecord
  belongs_to :item
  belongs_to :category, counter_cache: true
  belongs_to :category_node, foreign_key: "category_id"
  validates :category_id, uniqueness: {scope: :item_id}
end
