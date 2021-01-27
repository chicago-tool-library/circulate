class Membership < ApplicationRecord
  class PendingMembership < StandardError; end

  belongs_to :member
  has_one :adjustment, as: "adjustable"

  scope :active, -> { where("started_at <= ? AND ended_at >= ?", Time.current, Time.current) }
  scope :pending, -> { where(started_at: nil, ended_at: nil) }
  scope :ended, -> { where("ended_at <= ?", Time.current).order("ended_at ASC") }
  scope :expiring_before, ->(date) { where("ended_at <= ?", date) }

  validate :no_overlapping_dates
  validate :start_after_end

  def amount
    adjustment ? adjustment.amount * -1 : Money.new(0)
  end

  def pending?
    started_at.nil? && ended_at.nil?
  end

  def ended?
    ends_within?(Time.current)
  end

  def ends_within?(day)
    ended_at && ended_at < day
  end

  def status_text
    if pending?
      "pending"
    elsif ended?
      "ended on #{ended_at.to_s(:month_day_year)}"
    else
      "ends on #{ended_at.to_s(:month_day_year)}"
    end
  end

  def start!(now = Time.current)
    update!(started_at: now, ended_at: now + 364.days)
  end

  def self.next_start_date_for_member(member, now: Time.current.to_date)
    # no safe start date if there is a pending membership
    return nil if member.pending_membership

    # renewal memberships should start on the day after the active one ends
    return member.active_membership.ended_at + 1.day if member.active_membership

    # if there isn't an active membership (this includes if there was one that
    # has already ended), it can start today
    now
  end

  def self.create_for_member(member, amount: 0, source: nil, start_membership: false, now: Time.current.to_date, square_transaction_id: nil)
    if start_membership
      start_date = next_start_date_for_member(member, now: now)
      raise PendingMembership.new("member with pending membership can't start a new membership") unless start_date

      membership = member.memberships.create!(started_at: start_date, ended_at: start_date + 364.days)
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
      "started_at BETWEEN ? AND ? OR ended_at BETWEEN ? AND ?",
      started_at, ended_at, started_at, ended_at
    ).count

    errors.add(:base, "can't overlap with another membership") if overlapping > 0
  end

  def start_after_end
    return true unless started_at && ended_at

    if started_at > ended_at
      errors.add(:started_at, "must start before end")
      errors.add(:ended_at, "must end after start")
    end
  end
end
