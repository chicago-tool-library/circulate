class LoanSummary < ApplicationRecord
  self.primary_key = :initial_loan_id

  belongs_to :item
  belongs_to :latest_loan, class_name: "Loan"
  belongs_to :member
  has_one :adjustment, -> { unscope(where: :adjutable_type).where(adjustable_type: 'Loan') }, as: :adjustable

  scope :active_today, ->(date) {
    morning = date.beginning_of_day.utc
    night = date.end_of_day.utc
    where("loan_summaries.created_at BETWEEN ? AND ? OR loan_summaries.ended_at BETWEEN ? AND ?", morning, night, morning, night)
  }

  scope :active, -> { where(ended_at: nil) }
  scope :checked_out, -> { where(ended_at: nil) }
  scope :overdue, -> { checked_out.where("due_at < ?", Time.current.beginning_of_day) }
  scope :returned, -> { where.not(ended_at: nil) }
  scope :recently_returned, -> { where.not(ended_at: nil).where("loan_summaries.ended_at >= ?", Time.current - 30.days) }
  scope :by_end_date, -> { order(ended_at: :asc) }

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
