class LoanSummary < ApplicationRecord
  self.primary_key = :initial_loan_id

  belongs_to :item
  belongs_to :latest_loan, class_name: "Loan"
  belongs_to :member
  has_one :adjustment, -> { unscope(where: :adjutable_type).where(adjustable_type: "Loan") }, as: :adjustable
  has_many :renewal_requests, foreign_key: "loan_id"

  scope :active_on, ->(date) {
    morning = date.beginning_of_day.utc
    night = date.end_of_day.utc
    where("loan_summaries.created_at BETWEEN :morning AND :night OR loan_summaries.ended_at BETWEEN :morning AND :night OR renewal_requests.updated_at BETWEEN :morning AND :night", morning: morning, night: night).includes(:renewal_requests).references(:renewal_requests)
  }

  scope :checked_out, -> { where(ended_at: nil) }
  scope :due_on, ->(day) { where("due_at BETWEEN ? AND ?", day.beginning_of_day.utc, day.end_of_day.utc) }
  scope :overdue, -> { overdue_as_of(Time.current) }
  scope :overdue_as_of, ->(date) { checked_out.where(due_at: ...date) }
  scope :returned, -> { where.not(ended_at: nil) }
  scope :returned_since, ->(date) { where(loan_summaries: {ended_at: date..}) }

  scope :by_end_date, -> { order(ended_at: :asc) }
  scope :by_due_date, -> { order(due_at: :asc) }
  scope :chronologically, -> { order(created_at: :asc) }

  acts_as_tenant :library

  def item
    super || NullItem.new
  end

  def ended?
    ended_at.present?
  end

  def renewed?
    renewal_count > 0
  end

  def readonly?
    true
  end

  def overdue_as_of?(time)
    !ended? && due_at < time
  end

  def renewal_request_rejected?
    renewal_requests.max_by { |r| r.created_at }&.rejected?
  end
end
