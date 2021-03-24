class Hold < ApplicationRecord
  HOLD_LENGTH = 14.days

  has_many :appointment_holds
  has_many :appointments, through: :appointment_holds

  belongs_to :member
  belongs_to :item, counter_cache: true
  belongs_to :creator, class_name: "User"
  belongs_to :loan, required: false

  scope :active, ->(now = Time.current) { where("ended_at IS NULL AND (started_at IS NULL OR started_at > ?)", now - HOLD_LENGTH) }
  scope :inactive, ->(now = Time.current) { ended.or(expired(now)) }
  scope :ended, -> { where("ended_at IS NOT NULL") }
  scope :expired, ->(now = Time.current) { where("started_at < ?", now - HOLD_LENGTH) }
  scope :started, -> { where("started_at IS NOT NULL") }

  def self.active_hold_count_for_item(item)
    active.where(item: item).count
  end

  def lend(loan, now: Time.current)
    update!(
      loan: loan,
      ended_at: now
    )
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
      started_at: now
    )
  end

  def expires_at
    started_at + HOLD_LENGTH if started_at.present?
  end

  # A hold that timed out
  def expired?(now = Time.current)
    started_at && expires_at < now
  end

  # A hold whose clock has started ticking
  def started?
    started_at.present?
  end

  def previous_active_holds
    Hold.active.where("created_at < ?", created_at).where(item: item).where.not(member: member).order(:ended_at).to_a
  end

  def ready_for_pickup?
    # Holds for uncounted items are always ready to be picked up
    unless item.borrow_policy.uniquely_numbered?
      return true
    end

    # For uniquely numbered items there need to be no earlier holds
    # and the item needs to be in the library
    previous_active_holds.empty? && item.available?
  end

  def upcoming_appointment
    member.upcoming_appointment_of(self)
  end

  def self.start_waiting_holds(now: Time.current)
    started = 0

    active.includes(item: :borrow_policy).find_each do |hold|
      if hold.started?
        Rails.logger.debug "[hold #{hold.id}]: already started"
        next
      end

      unless hold.ready_for_pickup?
        Rails.logger.debug "[hold #{hold.id}]: not ready for pickup"
        next
      end

      Rails.logger.debug "[hold #{hold.id}]: ready to start"
      hold.start!(now)
      started += 1
    end

    Rails.logger.debug "Audit active holds: started #{started}."

    started
  end
end
