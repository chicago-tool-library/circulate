class Note < ApplicationRecord
  belongs_to :creator, class_name: "User"
  belongs_to :notable, polymorphic: true

  has_rich_text :body

  validates :body, presence: true

  scope :by_creation_date, -> { order(created_at: :asc) }
  scope :newest_first, -> { order(created_at: :desc) }
end
