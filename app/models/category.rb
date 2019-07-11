class Category < ApplicationRecord
  has_many :categorizations, dependent: :destroy
  has_many :items, through: :categorizations

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true

  before_validation :assign_slug

  scope :sorted_by_name, -> { order("name ASC") }

  def assign_slug
    if slug.blank?
      self.slug = name.parameterize
    end
  end
end
