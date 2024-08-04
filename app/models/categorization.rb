class Categorization < ApplicationRecord
  belongs_to :categorized, polymorphic: true
  belongs_to :category, counter_cache: true
  belongs_to :category_node, foreign_key: "category_id"
  validates :category_id, uniqueness: {scope: :categorized_id}

  after_destroy :refresh_category_nodes
  after_save :refresh_category_nodes

  private

  def refresh_category_nodes
    CategoryNode.refresh
  end
end
