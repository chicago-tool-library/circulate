class TicketUpdate < ApplicationRecord
  belongs_to :ticket, touch: true
  belongs_to :creator, class_name: "User"
  belongs_to :audit, class_name: "Audited::Audit", required: false

  has_rich_text :body
  validates :body, presence: true
  validates :time_spent, numericality: {allow_blank: true}
end
