# frozen_string_literal: true

class Categorization < ApplicationRecord
  belongs_to :item
  belongs_to :category, counter_cache: true
  belongs_to :category_node, foreign_key: "category_id"
  validates :category_id, uniqueness: { scope: :item_id }

  after_save :refresh_category_nodes
  after_destroy :refresh_category_nodes

  private
    def refresh_category_nodes
      CategoryNode.refresh
    end
end
