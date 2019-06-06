class Loan < ApplicationRecord
  belongs_to :item
  belongs_to :member
  has_one :adjustment, as: :adjustable

  validates :due_at, presence: true
  validates_numericality_of :ended_at, allow_nil: true, greater_than_or_equal_to: ->(loan){ loan.created_at }

  validates_each :item_id do |record, attr, value|
    if !value
      record.errors.add(attr, "does not exist")
    elsif record.item.active_loan && record.item.active_loan.id != record.id
      record.errors.add(attr, "is already on loan")
    elsif !record.item.active?
      record.errors.add(attr, "is not available to loan")
    end
  end

  scope :active, -> { where("ended_at IS NULL").includes(:item) }
  scope :recently_returned, -> { where("ended_at IS NOT NULL AND ended_at >= ?", Time.current - 7.days).includes(:item) }
  scope :by_creation_date, -> { order("created_at ASC") }

  def ended?
    ended_at.present?
  end
end
