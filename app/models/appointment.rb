class Appointment < ApplicationRecord
  has_many :appointment_holds, dependent: :destroy
  has_many :appointment_loans, dependent: :destroy
  has_many :holds, through: :appointment_holds
  has_many :loans, through: :appointment_loans
  belongs_to :member

  validate :ends_at_later_than_starts_at, :date_present
  validate :starts_before_holds_expire, if: :member_updating
  validate :item_present, unless: :staff_updating

  scope :upcoming, -> { where("starts_at > ?", Time.zone.now).order(:starts_at) }
  scope :today_or_later, -> { where("starts_at > ?", Time.zone.now.beginning_of_day).order(:starts_at) }
  scope :chronologically, -> { order("starts_at ASC") }
  scope :simultaneous, ->(appointment) { where(starts_at: appointment.starts_at, ends_at: appointment.ends_at).where.not(id: appointment.id) }

  attr_accessor :member_updating, :staff_updating

  def time_range_string
    starts_at.to_s + ".." + ends_at.to_s
  end

  def time_range_string=(string)
    if string.present?
      times = string.split("..")
      self.starts_at = DateTime.parse times[0]
      self.ends_at = DateTime.parse times[1]
    end
  rescue Date::Error
    # ignore parsing error
  end

  def completed?
    completed_at.present?
  end

  def merge!(other_appointment)
    transaction do
      holds << other_appointment.holds
      loans << other_appointment.loans
      update!(comment: "#{comment}\n\n#{other_appointment.comment}".strip) unless other_appointment.comment.blank?
      other_appointment.destroy!
    end
  end

  def cancel_if_no_items!
    destroy! if no_items?
  end

  private

  def no_items?
    holds.empty? && loans.empty?
  end

  def item_present
    if no_items?
      errors.add(:base, "Please select an item to pick-up or return for your appointment")
    end
  end

  def date_present
    if starts_at.nil? || ends_at.nil?
      errors.add(:base, "Please select a date and time for this appointment.")
    end
  end

  def ends_at_later_than_starts_at
    return if ends_at.blank? || starts_at.blank?

    if ends_at < starts_at
      errors.add(:ends_at, "must be after the starts_at date")
    end
  end

  def starts_before_holds_expire
    holds_first_expire = holds.filter_map(&:expires_at).min
    return unless starts_at

    before_holds_expire = holds_first_expire.nil? || starts_at <= holds_first_expire
    unless before_holds_expire
      errors.add(:base, "Please pick an appointment on or before hold expires on #{holds_first_expire.strftime("%a, %-m/%-d")}.")
    end
  end
end
