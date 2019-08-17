class LoanSummary < ApplicationRecord
  self.primary_key = :initial_loan_id

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
