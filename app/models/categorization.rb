class Categorization < ApplicationRecord
  belongs_to :item
  belongs_to :category, counter_cache: true
  belongs_to :category_node, foreign_key: "category_id"
  validates :category_id, uniqueness: {scope: :item_id}

  after_commit :refresh_category_nodes

  after_save :update_category_item_counts
  after_destroy :update_category_item_counts

  private

  # update categorization_counts
  # TODO remove this once the we're using the new status-based counts
  def refresh_category_nodes
    CategoryNode.refresh
  end

  def update_category_item_counts
    category.update_item_counts
  end
end
