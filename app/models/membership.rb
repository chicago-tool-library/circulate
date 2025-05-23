class Membership < ApplicationRecord
  class PendingMembership < StandardError; end

  enum :membership_type, {
    initial: "initial",
    renewal: "renewal"
  }

  belongs_to :member
  has_one :adjustment, as: "adjustable"
  acts_as_tenant :library

  scope :active, -> { where("started_at <= ? AND ended_at >= ?", Time.current, Time.current) }
  scope :pending, -> { where(started_at: nil, ended_at: nil) }
  scope :ended, -> { where(ended_at: ..Time.current).order("ended_at ASC") }
  scope :expiring_before, ->(date) { where(ended_at: ..date) }

  scope :for_export, -> {
    select_clauses = year_range_for_export.flat_map { |year|
      [
        %{SUM(adjustments.amount_cents * -1) FILTER (WHERE date_part('year', adjustments.created_at) = #{year}) AS "#{year}_amount"},
        %{MAX(memberships.started_at) FILTER (WHERE date_part('year', memberships.started_at) = #{year}) AS "#{year}_started_at"},
        # Can use ANY_VALUE() instead of MIN() on postgres 16+.
        %(MIN(memberships.membership_type) FILTER (WHERE date_part('year', memberships.created_at) = #{year}) AS "#{year}_membership_type")
      ]
    }

    left_joins(:adjustment).select(:member_id, *select_clauses).group(:member_id)
  }

  validates :membership_type, inclusion: {in: membership_types.keys}
  validate :no_overlapping_dates
  validate :start_after_end

  def self.year_range_for_export
    first_year = minimum(:started_at).year
    last_year = maximum(:started_at).year
    (first_year..last_year)
  end

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
      "ended on #{ended_at.to_fs(:month_day_year)}"
    else
      "ends on #{ended_at.to_fs(:month_day_year)}"
    end
  end

  def start!(now = Time.current)
    update!(started_at: now, ended_at: now + 364.days)
  end

  def self.next_start_date_for_member(member, now: Time.current)
    # no safe start date if there is a pending membership
    return nil if member.pending_membership

    # renewal memberships should start as soon as the last one ends to avoid gaps
    return member.last_membership.ended_at if member.active_membership

    # if there isn't an active membership (this includes if there was one that
    # has already ended), it can start today
    now
  end

  def self.create_for_member(member, amount: 0, source: nil, start_membership: false, now: Time.current, square_transaction_id: nil)
    # Is this the first membership for this member?
    membership_type = member.memberships.present? ? "renewal" : "initial"

    if start_membership
      start_date = next_start_date_for_member(member, now: now)
      raise PendingMembership.new("member with pending membership can't start a new membership") unless start_date

      membership = member.memberships.create!(started_at: start_date, ended_at: start_date + 365.days, library: member.library, membership_type:)
    else
      membership = member.memberships.create!(library: member.library, membership_type:)
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
      "started_at > ? AND started_at < ? OR ended_at > ? AND ended_at < ?",
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
