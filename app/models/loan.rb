class Loan < ApplicationRecord
  belongs_to :item, optional: true
  belongs_to :member
  has_one :adjustment, as: :adjustable
  has_many :renewals, class_name: "Loan", foreign_key: "initial_loan_id", dependent: :destroy
  has_many :renewal_requests, dependent: :destroy
  belongs_to :initial_loan, class_name: "Loan", optional: true
  has_one :hold, dependent: :nullify

  validates :due_at, presence: true
  validates :ended_at, numericality: {allow_nil: true, greater_than_or_equal_to: ->(loan) { loan.created_at }}
  validates :initial_loan_id, uniqueness: {scope: :renewal_count}, if: ->(l) { l.initial_loan_id.present? }

  validates_each :item_id do |record, attr, value|
    if value
      record.item.reload
      if record.item.checked_out_exclusive_loan && record.item.checked_out_exclusive_loan.id != record.id
        record.errors.add(attr, "is already on loan")
      elsif !record.item.active?
        record.errors.add(attr, "is not available to loan")
      end
    elsif record.new_record? && !record.renewal?
      record.errors.add(attr, "does not exist")
    end
  end

  scope :checked_out, -> { where(ended_at: nil) }
  scope :exclusive, -> { where(uniquely_numbered: true) }
  scope :by_creation_date, -> { order(created_at: :asc) }
  scope :by_end_date, -> { order(ended_at: :asc) }
  scope :due_on, ->(day) { where("due_at BETWEEN ? AND ?", day.beginning_of_day.utc, day.end_of_day.utc) }
  scope :due_whole_weeks_ago, ->(now = Time.current) {
    zone = Time.zone.tzinfo.name
    tonight = now.end_of_day
    where(
      <<~SQL,
        extract(day from
          date_trunc('day', ? at time zone ?) -
          date_trunc('day', loans.due_at at time zone 'utc' at time zone ?)
        )::integer % 7 = 0
        AND loans.due_at <= ?
      SQL
      now, zone, zone, tonight
    )
  }
  scope :overdue, -> { where(ended_at: nil).where(arel_table[:due_at].lt(Time.current)) }

  acts_as_tenant :library

  def item
    super || NullItem.new
  end

  def ended?
    ended_at.present?
  end

  def renewal?
    renewal_count > 0
  end

  def summary
    @summary ||= LoanSummary.find(initial_loan_id || id)
  end

  def self.lend(item, to:, now: Time.current)
    due_at = Event.next_open_day(now + item.borrow_policy.duration.days).end_of_day
    Loan.new(member: to, item: item, due_at: due_at, uniquely_numbered: item&.borrow_policy&.uniquely_numbered, created_at: now)
  end

  # Will another renewal exceed the maximum number of renewals?
  def within_renewal_limit?
    renewal_count < item.borrow_policy.renewal_limit
  end

  # Can a member renew this loan themselves without approval?
  def member_renewable?
    within_renewal_limit? && item.borrow_policy.member_renewable? && ended_at.nil?
  end

  # Can a member request this loan be renewed?
  def member_renewal_requestable?
    within_renewal_limit? && ended_at.nil? && !any_active_holds? && !renewal_requests.any?
  end

  # Does the item have any active holds?
  def any_active_holds?
    item.active_holds.any?
  end

  def status
    if due_at < Time.current
      "overdue"
    else
      "checked-out"
    end
  end

  def checked_out?
    ended_at.blank?
  end

  def latest_renewal_request
    renewal_requests.max_by { |r| r.created_at }
  end

  def upcoming_appointment
    member.upcoming_appointment_of(self)
  end
end
