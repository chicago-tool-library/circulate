class MaintenanceReport < ApplicationRecord
  belongs_to :item
  belongs_to :creator, class_name: "User"

  has_rich_text :body

  validates :title, presence: true
  validates :body, presence: true
end
