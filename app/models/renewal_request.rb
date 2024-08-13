class RenewalRequest < ApplicationRecord
  belongs_to :loan

  enum :status, {
    requested: "requested",
    approved: "approved",
    rejected: "rejected"
  }

  validates :status, inclusion: {in: RenewalRequest.statuses.keys}

  acts_as_tenant :library
end
