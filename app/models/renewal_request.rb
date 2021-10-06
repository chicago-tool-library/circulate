class RenewalRequest < ApplicationRecord
  belongs_to :loan
  belongs_to :loan_summary, foreign_key: "loan_id", primary_key: "initial_loan_id", optional: true

  enum status: {
    requested: "requested",
    approved: "approved",
    rejected: "rejected"
  }

  validates :status, inclusion: {in: RenewalRequest.statuses.keys}

  acts_as_tenant :library
end
