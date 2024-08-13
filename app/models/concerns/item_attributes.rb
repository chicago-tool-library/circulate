require "active_support/concern"

module ItemAttributes
  extend ActiveSupport::Concern
  included do
    has_many :categorizations, dependent: :destroy, as: :categorized
    has_many :categories, through: :categorizations,
      before_add: :cache_category_ids,
      before_remove: :cache_category_ids
    has_many :category_nodes, through: :categorizations

    has_rich_text :description

    enum :power_source, {
      solar: "solar",
      gas: "gas",
      air: "air",
      electric_corded: "electric (corded)",
      electric_battery: "electric (battery)"
    }

    validates :power_source, inclusion: {in: power_sources.keys}, allow_blank: true
  end

  class_methods do
    # none yet
  end

  def cache_category_ids(item)
    # no-op
  end
end
