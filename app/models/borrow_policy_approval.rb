class BorrowPolicyApproval < ApplicationRecord
  enum :status, {
    approved: "approved",
    rejected: "rejected",
    requested: "requested",
    revoked: "revoked"
  }, validate: true

  belongs_to :borrow_policy
  belongs_to :member

  validates :borrow_policy_id, uniqueness: {scope: :member_id}

  def self.ransackable_attributes(auth_object = nil)
    %w[status]
  end
end
