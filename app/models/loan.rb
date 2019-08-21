class Loan < ApplicationRecord
  belongs_to :item
  belongs_to :member
  has_one :adjustment, as: :adjustable
  has_many :renewals, class_name: "Loan", foreign_key: "initial_loan_id"
  belongs_to :initial_loan, class_name: "Loan", optional: true

  validates :due_at, presence: true
  validates_numericality_of :ended_at, allow_nil: true, greater_than_or_equal_to: ->(loan) { loan.created_at }

  validates_each :item_id do |record, attr, value|
    if !value
      record.errors.add(attr, "does not exist")
    elsif record.item.active_exclusive_loan && record.item.active_exclusive_loan.id != record.id
      record.errors.add(attr, "is already on loan")
    elsif !record.item.active?
      record.errors.add(attr, "is not available to loan")
    end
  end

  scope :active, -> { where("ended_at IS NULL").includes(:item) }
  scope :exclusive, -> { where(uniquely_numbered: true) }
  scope :recently_returned, -> { where("ended_at IS NOT NULL AND ended_at >= ?", Time.current - 7.days).includes(:item) }
  scope :by_creation_date, -> { order("created_at ASC") }
  scope :by_end_date, -> { order("ended_at ASC") }

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
        initial_loan_id: id,
        created_at: now,
        renewal_count: renewal_count + 1,
        due_at: now.end_of_day + item.borrow_policy.duration.days,
        uniquely_numbered: uniquely_numbered,
      )
    end
  end

  def return!(now = Time.current)
    # raise an error if already returned
    update!(ended_at: now)
    self
  end
end
