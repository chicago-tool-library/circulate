class Category < ApplicationRecord
  has_ancestry

  has_many :categorizations, dependent: :destroy

  validates :name, presence: true
  validates :slug, presence: true,  uniqueness: true

  before_validation :assign_slug

  scope :sorted_by_name, -> { order("name ASC") }

  def assign_slug
    if slug.blank?
      self.slug = name.parameterize
    end
  end

  def self.alpha_tree
    sort_by_ancestry(sorted_by_name)
  end
end
