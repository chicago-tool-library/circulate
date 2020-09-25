class Appointment < ApplicationRecord
  has_many :appointment_holds, dependent: :destroy
  has_many :appointment_loans, dependent: :destroy
  has_many :holds, through: :appointment_holds
  has_many :loans, through: :appointment_loans
  belongs_to :member

  validates :starts_at, :ends_at, presence: true

  validate :ends_at_later_than_starts_at

  scope :upcoming, -> { where("starts_at > ?", Time.zone.now).order(:starts_at) }

  private

  def ends_at_later_than_starts_at
    return if ends_at.blank? || starts_at.blank?

    if ends_at < starts_at
      errors.add(:ends_at, "must be after the starts_at date")
    end
  end
end
