class LoanSummary < ApplicationRecord
  self.primary_key = :initial_loan_id

  belongs_to :item
  belongs_to :latest_loan, class_name: "Loan"
  belongs_to :member
  has_one :adjustment, -> { unscope(where: :adjutable_type).where(adjustable_type: "Loan") }, as: :adjustable

  scope :active_on, ->(date) {
    morning = date.beginning_of_day.utc
    night = date.end_of_day.utc
    where("loan_summaries.created_at BETWEEN ? AND ? OR loan_summaries.ended_at BETWEEN ? AND ?", morning, night, morning, night)
  }

  scope :checked_out, -> { where(ended_at: nil) }
  scope :overdue, ->(date = Time.current) { checked_out.where "due_at < ?", date }
  scope :returned, -> { where.not(ended_at: nil) }
  scope :returned_since, ->(date) { where("loan_summaries.ended_at >= ?", date) }

  scope :renewable, ->(is_renewable = true) {
    operator = is_renewable ? :lt : :gteq
    checked_out.joins(item: :borrow_policy).where(arel_table[:renewal_count].send(operator, BorrowPolicy.arel_table[:renewal_limit]))
  }

  scope :by_end_date, -> { order(ended_at: :asc) }
  scope :by_due_date, -> { order(due_at: :asc, created_at: :asc) }
  scope :chronologically, -> { order(created_at: :asc) }

  def ended?
    ended_at.present?
  end

  def renewed?
    renewal_count > 0
  end

  def renewable?
    renewal_count < item.borrow_policy.renewal_limit
  end

  def readonly?
    true
  end

  def overdue_as_of?(time)
    !ended? && due_at < time
  end
end
