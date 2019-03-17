class Category < ApplicationRecord
  validates :name, presence: true
  validates :slug, presence: true,  uniqueness: true

  before_validation :assign_slug

  def assign_slug
    if slug.blank?
      self.slug = name.parameterize
    end
  end
end
