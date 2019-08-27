class LoanSummary < ApplicationRecord
  self.primary_key = :initial_loan_id

  belongs_to :item
  belongs_to :member

  scope :active_today, ->(date) {
    morning = date.beginning_of_day.utc
    night = date.end_of_day.utc
    where("loan_summaries.ended_at IS NULL OR loan_summaries.ended_at BETWEEN ? AND ?", morning, night)
  }

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
