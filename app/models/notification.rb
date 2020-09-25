class Notification < ApplicationRecord
  enum status: {
    pending: "pending",
    sent: "sent",
    bounced: "bounced",
    error: "error"
  }

  belongs_to :member, required: false

  validates :address, presence: true
  validates :action, presence: true
  validates :uuid, presence: true
  validates :status, inclusion: {in: Notification.statuses.keys}

  acts_as_tenant :library
end
