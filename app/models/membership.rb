class Membership < ApplicationRecord
  belongs_to :member
  has_one :adjustment, as: "adjustable"
  scope :active, -> { where("started_on <= ? AND ended_on >= ?", Time.current, Time.current) }

  def self.create_for_member(member, amount)
    membership = member.memberships.create!(started_on: @now.to_date, ended_on: @now.to_date + 364.days)
    member.adjustments.create!(amount: -amount, adjustable: membership)
    member.adjustments.create!(amount: amount)
    membership
  end
end
