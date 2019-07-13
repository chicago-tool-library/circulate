class Tag < ApplicationRecord
  has_many :taggings, dependent: :destroy
  has_many :items, through: :taggings

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true

  before_validation :assign_slug

  scope :sorted_by_name, -> { order("name ASC") }

  def assign_slug
    self.slug = name.parameterize
  end
end
