class PaymentMethod < ApplicationRecord
  belongs_to :user

  enum :status, {
    active: "active",
    expired: "expired",
    detached: "detached"
  }

  scope :active, -> { where(status: "active") }

  def detach!
    update!(status: self.class.statuses[:detached])
  end
end
