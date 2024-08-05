class TicketUpdate < ApplicationRecord
  belongs_to :ticket, touch: true
  belongs_to :creator, class_name: "User"
  belongs_to :audit, class_name: "Audited::Audit", optional: true

  has_rich_text :body
  validates :body, presence: true
  validates :time_spent, numericality: {allow_blank: true}

  acts_as_tenant :library

  scope :newest_first, -> { order(created_at: :desc) }
end
