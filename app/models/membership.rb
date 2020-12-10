class Membership < ApplicationRecord
  class PendingMembership < StandardError; end

  belongs_to :member
  has_one :adjustment, as: "adjustable"

  scope :active, -> { where("started_on <= ? AND ended_on >= ?", Time.current, Time.current) }
  scope :pending, -> { where(started_on: nil, ended_on: nil) }

  validate :no_overlapping_dates
  validate :start_after_end

  def amount
    adjustment ? adjustment.amount * -1 : Money.new(0)
  end

  def pending?
    started_on.nil? && ended_on.nil?
  end

  def start!(now = Time.current)
    update!(started_on: now, ended_on: now + 364.days)
  end

  def self.next_start_date_for_member(member, now: Time.current.to_date)
    # no safe start date if there is a pending membership
    return nil if member.pending_membership

    # renewal memberships should start on the day after the active one ends
    return member.active_membership.ended_on + 1.day if member.active_membership

    # if there isn't an active membership (this includes if there was one that
    # has already ended), it can start today
    now
  end

  def self.create_for_member(member, amount: 0, source: nil, start_membership: false, now: Time.current.to_date, square_transaction_id: nil)
    if start_membership
      start_date = next_start_date_for_member(member, now: now)
      raise PendingMembership.new("member with pending membership can't start a new membership") unless start_date

      membership = member.memberships.create!(started_on: start_date, ended_on: start_date + 364.days)
    else
      membership = member.memberships.create!
    end

    if amount > 0
      Adjustment.record_membership(membership, amount)
      Adjustment.record_member_payment(member, amount, source, square_transaction_id)
    end
    membership
  end

  private

  def no_overlapping_dates
    overlapping = member.memberships.where(
      "started_on BETWEEN ? AND ? OR ended_on BETWEEN ? AND ?",
      started_on, ended_on, started_on, ended_on
    ).count

    errors.add(:base, "can't overlap with another membership") if overlapping > 0
  end

  def start_after_end
    return true unless started_on && ended_on

    if started_on > ended_on
      errors.add(:started_on, "must start before end")
      errors.add(:ended_on, "must end after start")
    end
  end
end
