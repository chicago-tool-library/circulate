class MaintenanceReport < ApplicationRecord
  belongs_to :item
  belongs_to :creator, class_name: "User"
  belongs_to :audit, class_name: "Audited::Audit", required: false

  has_rich_text :body

  validates :title, presence: true
  validates :body, presence: true
end
