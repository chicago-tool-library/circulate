class Appointment < ApplicationRecord
  has_many :appointment_holds, dependent: :destroy
  has_many :appointment_loans, dependent: :destroy
  has_many :holds, through: :appointment_holds
  has_many :loans, through: :appointment_loans
  belongs_to :member

  validate :ends_at_later_than_starts_at, :item_present, :date_present

  scope :upcoming, -> { where("starts_at > ?", Time.zone.now).order(:starts_at) }
  scope :today_or_later, -> { where("starts_at > ?", Time.zone.now.beginning_of_day).order(:starts_at) }
  scope :chronologically, -> { order("starts_at ASC") }

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

  private

  def item_present
    if holds.empty? && loans.empty?
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
end
