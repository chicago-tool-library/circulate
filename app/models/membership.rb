class Membership < ApplicationRecord
  belongs_to :member
  has_one :adjustment, as: "adjustable"
  scope :active, -> { where("started_on <= ? AND ended_on >= ?", Time.current, Time.current) }
  acts_as_tenant :library
  validates_uniqueness_to_tenant :member_id

  def amount
    adjustment ? adjustment.amount * -1 : Money.new(0)
  end

  def self.create_for_member(member, amount: 0, source: nil, now: Time.current.to_date, square_transaction_id: nil)
    membership = member.memberships.create!(started_on: now, ended_on: now + 364.days)
    if amount > 0
      Adjustment.record_membership(membership, amount)
      Adjustment.record_member_payment(member, amount, source, square_transaction_id)
    end
    membership
  end
end
