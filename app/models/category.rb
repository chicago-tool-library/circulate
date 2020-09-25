class Category < ApplicationRecord
  has_many :categorizations, dependent: :destroy
  has_many :items, through: :categorizations

  belongs_to :parent, class_name: "Category", required: false
  has_many :children, class_name: "Category", foreign_key: "parent_id", dependent: :destroy

  validates :name, presence: true, uniqueness: {scope: :library_id}
  validates :slug, presence: true, uniqueness: {scope: :library_id}

  before_validation :assign_slug
  after_commit :refresh_category_nodes

  validate :prevent_circular_reference

  scope :sorted_by_name, -> { order("name ASC") }
  scope :top_level, -> { where(parent_id: nil) }

  acts_as_tenant :library

  def assign_slug
    if slug.blank? || (name_changed? && !slug_changed?)
      self.slug = name.parameterize
    end
  end

  def prevent_circular_reference
    category = self
    while (parent = category.parent)
      if parent.id == id
        errors.add(:parent_id, "can't be set to a child")
        break
      end
      category = parent
    end
  end

  def refresh_category_nodes
    CategoryNode.refresh
  end
end
