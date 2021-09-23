class Loan < ApplicationRecord
  belongs_to :item, optional: true
  belongs_to :member
  has_one :adjustment, as: :adjustable
  has_many :renewals, class_name: "Loan", foreign_key: "initial_loan_id"
  has_many :renewal_requests, dependent: :destroy
  belongs_to :initial_loan, class_name: "Loan", optional: true
  has_one :hold, dependent: :nullify

  validates :due_at, presence: true
  validates_numericality_of :ended_at, allow_nil: true, greater_than_or_equal_to: ->(loan) { loan.created_at }
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

  def self.open_days
    [
      0, # Sunday
      3, # Wednesday
      4, # Thursday
      6 # Saturday
    ]
  end

  def self.next_open_day(time)
    day = time
    until open_days.include? day.wday
      day += 1.day
    end
    day
  end

  def self.lend(item, to:, now: Time.current)
    due_at = next_open_day(now.end_of_day + item.borrow_policy.duration.days)
    Loan.new(member: to, item: item, due_at: due_at, uniquely_numbered: item&.borrow_policy&.uniquely_numbered)
  end

  # Will another renewal exceed the maximum number of renewals?
  # TODO rename this within_renewal_limit?
  def renewable?
    renewal_count < item.borrow_policy.renewal_limit
  end

  # Can a member renew this loan themselves without approval?
  def member_renewable?
    renewable? && within_borrow_policy_duration? && item.borrow_policy.member_renewable? && ended_at.nil?
  end

  # Can a member request this loan be renewed?
  def member_renewal_requestable?
    renewable? && within_borrow_policy_duration? && ended_at.nil? && !item.active_holds.any? && !renewal_requests.any?
  end

  # Is it after the loan was created? This method is basically a no-op and can likely be removed.
  def within_borrow_policy_duration?
    due_at - Time.current <= item.borrow_policy.duration.days
  end

  def status
    if due_at < Time.now
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
