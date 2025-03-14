class BorrowPolicyApproval < ApplicationRecord
  enum :status, {
    approved: "approved",
    rejected: "rejected",
    requested: "requested",
    revoked: "revoked"
  }, validate: true

  belongs_to :borrow_policy
  belongs_to :member
end
