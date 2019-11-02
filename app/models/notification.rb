class Notification < ApplicationRecord
  enum status: {
    pending: "pending",
    sent: "sent",
    bounced: "bounced",
    error: "error",
  }

  belongs_to :member

  validates :address, presence: true
  validates :action, presence: true
  validates :uuid, presence: true
  validates :status, inclusion: {in: Notification.statuses.keys}
end
