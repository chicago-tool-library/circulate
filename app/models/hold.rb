class Hold < ApplicationRecord
  HOLD_LENGTH = 7.days

  has_one :appointment_hold, dependent: :destroy
  has_one :appointment, through: :appointment_hold

  belongs_to :member
  belongs_to :item, counter_cache: true
  belongs_to :creator, class_name: "User"
  belongs_to :loan, required: false

  scope :active, ->(now = Time.current) {
    where(ended_at: nil).and(
      where(started_at: nil).or(where(expires_at: now..))
    )
  }
  scope :inactive, ->(now = Time.current) { ended.or(expired(now)) }
  scope :ended, -> { where("ended_at IS NOT NULL") }
  scope :expired, ->(now = Time.current) { where("expires_at < ?", now) }
  scope :started, -> { where("started_at IS NOT NULL") }
  scope :waiting, -> { where("started_at IS NULL") }

  scope :recent_first, -> { order("created_at desc") }

  validates :item, presence: true
  validates :expires_at, presence: {
    message: "is required when started_at is set"
  }, if: -> { started_at.present? }

  validate :ensure_items_are_holdable, on: :create

  acts_as_tenant :library

  def self.active_hold_count_for_item(item)
    active.where(item: item).count
  end

  # active and inactive are mutually exclusive
  # ended, expired, and started check for specific states
  # and should not be used as proxies for inactive.

  # A new hold
  def active?(now = Time.current)
    !inactive?(now)
  end

  # A hold that was picked up or timed out
  def inactive?(now = Time.current)
    ended? || expired?(now)
  end

  # A hold that was picked up
  def ended?
    ended_at.present?
  end

  def start!(now = Time.current)
    update!(
      started_at: now,
      expires_at: (now + HOLD_LENGTH).end_of_day
    )
  end

  def cancel!
    if appointment.present?
      appointment_hold.destroy!
      appointment.cancel_if_no_items!
    end

    destroy!
  end

  # A hold that timed out
  def expired?(now = Time.current)
    started? && expires_at < now
  end

  # A hold whose clock has started ticking
  def started?
    started_at.present?
  end

  def previous_active_holds(now = Time.current)
    Hold.active(now).where("created_at < ?", created_at).where(item: item).where.not(member: member).order(:ended_at).to_a
  end

  def ready_for_pickup?(now = Time.current)
    # Holds for uncounted items are always ready to be picked up
    unless item.borrow_policy.uniquely_numbered?
      return true
    end

    # For uniquely numbered items there need to be no earlier holds
    # and the item needs to be in the library
    previous_active_holds(now).empty? && item.available?
  end

  def upcoming_appointment
    member.upcoming_appointment_of(self)
  end

  def self.next_waiting_hold_dates
    active.started.select("expires_at, count(holds.id)").group("expires_at").order("expires_at ASC")
      .map { |hold| [hold.expires_at, hold.count] }
  end

  def self.extend_started_holds_until(date)
    Hold.active.started.where("expires_at < ?", date).update_all(expires_at: date)
  end

  def self.start_waiting_holds(now = Time.current, &block)
    started = 0

    active(now).includes(item: :borrow_policy).find_each do |hold|
      if hold.item.status == Item.statuses[:maintenance]
        Rails.logger.debug "[hold #{hold.id}]: item in maintenance mode"
        next
      end

      unless hold.item.holdable?
        Rails.logger.debug "[hold #{hold.id}]: item is not holdable"
        next
      end

      if hold.started?
        Rails.logger.debug "[hold #{hold.id}]: already started"
        next
      end

      unless hold.ready_for_pickup?(now)
        Rails.logger.debug "[hold #{hold.id}]: not ready for pickup"
        next
      end

      Rails.logger.debug "[hold #{hold.id}]: ready to start"
      hold.start!(now)
      yield hold if block # send email
      started += 1
    end

    Rails.logger.debug "Audit active holds: started #{started}."

    started
  end

  private

  def ensure_items_are_holdable
    return unless item
    item.reload
    unless item.holdable?
      errors.add(:item, "can not be placed on hold")
    end
  end
end
