class LoanSummary < ApplicationRecord
  self.primary_key = :initial_loan_id

  belongs_to :item

  def ended?
    ended_at.present?
  end

  def renewed?
    renewal_count > 0
  end

  def readonly?
    true
  end
end
