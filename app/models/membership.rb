class Membership < ApplicationRecord
  belongs_to :member
  has_one :adjustment, as: "adjustable"
  scope :active, -> { where("started_on <= ? AND ended_on >= ?", Time.current, Time.current) }

  def self.create_for_member(member, amount, now:Time.current.to_date, square_transaction_id:nil)
    membership = member.memberships.create!(started_on: now, ended_on: now + 364.days)
    Adjustment.record_membership(membership, amount)
    Adjustment.record_member_payment(member, amount, "square", square_transaction_id)
    membership
  end
end
