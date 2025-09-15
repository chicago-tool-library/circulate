require "active_support/concern"

module ItemCategorization
  extend ActiveSupport::Concern

  included do
    has_many :categorizations, dependent: :destroy, as: :categorized
    has_many :categories, through: :categorizations,
      before_add: :cache_category_ids,
      before_remove: :cache_category_ids
    has_many :category_nodes, through: :categorizations
  end

  class_methods do
    # none yet
  end

  def cache_category_ids(item)
    # no-op
  end
end
