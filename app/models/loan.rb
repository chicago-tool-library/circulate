class Loan < ApplicationRecord
  belongs_to :item
  belongs_to :member
  has_one :adjustment, as: :adjustable
  has_many :renewals, class_name: "Loan", foreign_key: "initial_loan_id"
  belongs_to :initial_loan, class_name: "Loan", optional: true

  validates :due_at, presence: true
  validates_numericality_of :ended_at, allow_nil: true, greater_than_or_equal_to: ->(loan) { loan.created_at }

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
  scope :due_whole_weeks_ago, -> {
    zone = Time.zone.tzinfo.name
    checked_out.where(
      <<~SQL,
        extract(day from date_trunc('day', now() at time zone ?) - 
        date_trunc('day', loans.due_at at time zone 'utc' at time zone ?))::integer % 7 = 0
      SQL
      zone, zone
    )
  }

  def ended?
    ended_at.present?
  end

  def renewal?
    renewal_count > 0
  end

  def renew!(now = Time.current)
    transaction do
      return!(now)
      Loan.create!(
        member_id: member_id,
        item_id: item_id,
        initial_loan_id: initial_loan_id || id,
        renewal_count: renewal_count + 1,
        due_at: due_at + item.borrow_policy.duration.days,
        uniquely_numbered: uniquely_numbered,
        created_at: now,
      )
    end
  end

  def return!(now = Time.current)
    # raise an error if already returned
    update!(ended_at: now)
    self
  end
end
