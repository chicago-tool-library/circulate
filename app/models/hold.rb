class Hold < ApplicationRecord
  HOLD_LENGTH = 14.days

  has_many :appointment_holds
  has_many :appointments, through: :appointment_holds

  belongs_to :member
  belongs_to :item, counter_cache: true
  belongs_to :creator, class_name: "User"
  belongs_to :loan, required: false

  scope :active, ->(now = Time.current) { where("ended_at IS NULL AND created_at > ?", now - HOLD_LENGTH) }
  scope :inactive, ->(now = Time.current) { ended.or(expired) }
  scope :ended, -> { where("ended_at IS NOT NULL") }
  scope :expired, ->(now = Time.current) { where("created_at < ?", now - HOLD_LENGTH) }

  def self.active_hold_count_for_item(item)
    active.where(item: item).count
  end

  def lend(loan, now: Time.current)
    update!(
      loan: loan,
      ended_at: now
    )
  end

  def active?
    ended_at.blank? && !expired?
  end

  def ended?
    ended_at.present?
  end

  def expired?(now = Time.current)
    (created_at + HOLD_LENGTH) > now
  end

  def previous_active_holds
    Hold.active.where("created_at < ?", created_at).where(item: item).where.not(member: member).order(:ended_at).to_a
  end

  def ready_for_pickup?
    previous_active_holds.empty? && item.available?
  end

  def upcoming_appointment
    member.upcoming_appointment_of(self)
  end
end
