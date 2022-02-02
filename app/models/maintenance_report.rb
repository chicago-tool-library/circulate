class MaintenanceReport < ApplicationRecord
  belongs_to :item
  belongs_to :creator, class_name: "User"

  has_rich_text :body

  validates :body, presence: true
end
