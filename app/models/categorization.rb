class Categorization < ApplicationRecord
  belongs_to :item
  belongs_to :category, counter_cache: true
  validates :category_id, uniqueness: {scope: :item_id}

  after_commit :refresh_category_nodes

  # update categorization_counts
  def refresh_category_nodes
    CategoryNode.refresh
  end
end
