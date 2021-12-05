class LibraryUpdate < ApplicationRecord
  acts_as_tenant :library

  validates :title, presence: true

  has_rich_text :body

  scope :published, -> { where(published: true) }
  scope :newest_first, -> { order(created_at: :desc) }
end
