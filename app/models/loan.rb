class Loan < ApplicationRecord
  belongs_to :item
  belongs_to :member
  has_one :adjustment, as: :adjustable
  has_many :renewals, class_name: "Loan", foreign_key: "initial_loan_id"
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
    else
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

  def ended?
    ended_at.present?
  end

  def renewal?
    renewal_count > 0
  end

  def self.open_days
    [
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

  def renewable?
    renewal_count < item.borrow_policy.renewal_limit
  end

  def member_renewable?
    renewable? && within_borrow_policy_duration? && item.borrow_policy.member_renewable?
  end

  def within_borrow_policy_duration?
    due_at - Time.current <= item.borrow_policy.duration.days
  end

  def renew!(now = Time.current)
    transaction do
      return!(now)

      period_start_date = [due_at, now.end_of_day].max
      Loan.create!(
        member_id: member_id,
        item_id: item_id,
        initial_loan_id: initial_loan_id || id,
        renewal_count: renewal_count + 1,
        due_at: self.class.next_open_day(period_start_date + item.borrow_policy.duration.days),
        uniquely_numbered: uniquely_numbered,
        created_at: now
      )
    end
  end

  def undo_renewal!
    transaction do
      destroy!
      target = if renewal_count > 1
        initial_loan.renewals.order(created_at: :desc).where.not(id: id).first
      else
        initial_loan
      end
      target.update!(ended_at: nil)
      target
    end
  end

  def return!(now = Time.current)
    # raise an error if already returned
    update!(ended_at: now)
    self
  end

  def status
    if due_at < Time.now
      "overdue"
    else
      "checked-out"
    end
  end
end
