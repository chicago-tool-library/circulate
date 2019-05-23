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

  # Return an Array of all categories in alphabetized hierarchy order
  def self.alpha_tree
    sort_by_ancestry(all) { |a, b| a.name <=> b.name }
  end

  # Return a string representation of alpha_tree, using indentation
  # to indicate nesting
  def self.inspect_all
    alpha_tree.map { |c| ("  " * c.ancestor_ids.size) + c.name }.join("\n")
  end
end
