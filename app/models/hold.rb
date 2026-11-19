class Hold < ApplicationRecord
  DEFAULT_HOLD_DURATION = 7 # days

  has_one :appointment_hold, dependent: :destroy
  has_one :appointment, through: :appointment_hold

  belongs_to :member
  belongs_to :item, counter_cache: true
  belongs_to :creator, class_name: "User"
  belongs_to :loan, optional: true

  # sequential_updates moves items one at a time to deal with having a uniqueness constraint on [item_id, position]
  # if/when that becomes a performance issue, we can consider making the constraint deferred
  acts_as_list scope: :item, sequential_updates: true

  scope :active, ->(now = Time.current) {
    where(ended_at: nil).and(
      where(started_at: nil).or(where(expires_at: now..))
    )
  }
  scope :inactive, ->(now = Time.current) { ended.or(expired(now)) }
  scope :ended, -> { where.not(ended_at: nil) }
  scope :expired, ->(now = Time.current) { where(expires_at: ...now) }
  scope :started, -> { where.not(started_at: nil) }
  scope :waiting, -> { where(started_at: nil) }

  scope :recent_first, -> { order("created_at desc") }
  scope :ordered_by_position, -> { order("position asc") }

  validates :expires_at, presence: {
    message: "is required when started_at is set"
  }, if: :started_at?

  validate :ensure_items_are_holdable, :ensure_member_is_within_borrow_policy_limit, on: :create

  # When a ready hold ends without becoming a loan (cancelled, ended by staff),
  # the item is back on the shelf for the next member in line. Start their hold
  # now rather than waiting for the scheduled task, so a walk-in can't slip in
  # ahead of the line in the meantime.
  # (Two methods because Rails keeps only the last after_commit registered for
  # a given method name.)
  after_commit :promote_next_hold, on: :update, if: :released_item?
  after_commit :promote_next_hold_after_destroy, on: :destroy, if: -> { started? && !ended? }

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

  # A hold that was picked up or a hold on an item that was retired
  def ended?
    ended_at.present?
  end

  def start!(now = Time.current)
    duration = item.hold_duration || DEFAULT_HOLD_DURATION
    expires_at = Event.next_open_day(now + duration.days).end_of_day

    update!(
      started_at: now,
      expires_at: expires_at
    )
  end

  def cancel!
    remove_from_appointment!
    destroy!
  end

  # Staff lent the item over this ready hold. Put the hold back in line without
  # touching its position, so the member is still next and gets a fresh pickup
  # window when the item comes back. Any appointment they booked for it can't
  # happen, so the hold comes off that too. Returns what happened to the
  # appointment (nil, :removed or :cancelled) for the member's notification.
  def return_to_line!(now = Time.current)
    update!(started_at: nil, expires_at: nil)
    take_off_upcoming_appointment!(now)
  end

  # Takes the hold off an appointment that hasn't happened yet (today counts).
  # Returns nil if there was nothing to do, otherwise :removed, or :cancelled
  # when the appointment had nothing else on it.
  def take_off_upcoming_appointment!(now = Time.current)
    upcoming = appointment
    return if upcoming.blank? || upcoming.completed? || upcoming.starts_at < now.beginning_of_day

    remove_from_appointment!
    Appointment.exists?(upcoming.id) ? :removed : :cancelled
  end

  def remove_from_appointment!
    return if appointment.blank?

    appointment_hold.destroy!

    appointment.cancel_if_no_items!
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
    Hold.active(now).where(position: ...position).where(item: item).where.not(member: member).ordered_by_position.to_a
  end

  def ready_for_pickup?(now = Time.current)
    return false unless item.active?

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
    Hold.active.started.where(expires_at: ...date).update_all(expires_at: date)
  end

  def existing_items_counted_toward_limit
    return [] unless item && member

    @existing_items_counted_toward_limit ||= begin
      borrow_policy_id = item.borrow_policy_id
      holds = member.active_holds
        .joins(:item)
        .where(items: {borrow_policy_id:})
        .includes(item: :borrow_policy)
      loans = member.loans
        .checked_out
        .joins(:item)
        .where(items: {borrow_policy_id:})
        .includes(item: :borrow_policy)

      holds.to_a + loans.to_a
    end
  end

  # Starts every hold that's ready and tells the members. Pass an item to only
  # look at that item's line.
  def self.start_waiting_holds_and_notify(item: nil)
    Time.use_zone("America/Chicago") do
      holds = []
      start_waiting_holds(item:) { |hold| holds << hold }

      holds.group_by(&:member).each do |member, member_holds|
        MemberMailer.with(member:, holds: member_holds).holds_available.deliver_now
        MemberTexter.new(member).holds_available(member_holds)
      end
    end
  end

  def self.start_waiting_holds(now = Time.current, item: nil, &block)
    started = 0

    scope = active(now).waiting.joins(:item).merge(Item.holdable)
    scope = scope.where(item:) if item
    scope.includes(:member, item: :borrow_policy).find_each do |hold|
      unless hold.ready_for_pickup?(now)
        Rails.logger.debug { "[hold #{hold.id}]: not ready for pickup" }
        next
      end

      Rails.logger.debug { "[hold #{hold.id}]: ready to start" }
      hold.start!(now)
      yield hold if block # send email
      started += 1
    end

    Rails.logger.debug { "Audit active holds: started #{started}." }

    started
  end

  private

  def released_item?
    saved_change_to_ended_at? && ended? && started? && loan_id.nil?
  end

  def promote_next_hold
    StartWaitingHoldsJob.perform_later(item_id)
  end
  alias_method :promote_next_hold_after_destroy, :promote_next_hold

  def ensure_items_are_holdable
    return unless item
    item.reload
    unless item.holdable?
      errors.add(:item, "can not be placed on hold")
    end

    borrow_policy_approval = member.borrow_policy_approvals.find_by(borrow_policy: item.borrow_policy)

    return unless item.borrow_policy.requires_approval?

    unless borrow_policy_approval&.approved?
      errors.add(:borrow_policy, "requires approval")
    end
  end

  def ensure_member_is_within_borrow_policy_limit
    return unless item && member && creator
    return if creator.has_role?(:staff)

    borrow_policy = item.borrow_policy
    return unless borrow_policy.limit_items_per_member?

    member.lock!

    if existing_items_counted_toward_limit.size >= borrow_policy.maximum_items_per_member
      tool_name = "#{borrow_policy.code}-Tool".pluralize(borrow_policy.maximum_items_per_member)
      errors.add(
        :base,
        :maximum_items_per_member,
        message: "You can have a maximum of #{borrow_policy.maximum_items_per_member} #{tool_name} checked out or on hold at one time."
      )
    end
  end
end
