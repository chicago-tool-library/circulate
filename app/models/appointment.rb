class Appointment < ApplicationRecord
  has_many :appointment_holds
  has_many :holds, through: :appointment_holds
  has_many :loans, through: :appointment_loans
  belongs_to :member

  validates :starts_at, :ends_at, presence: true
end
