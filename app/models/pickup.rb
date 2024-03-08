class Pickup < ApplicationRecord
  enum status: {
    building: "building",
    ready_for_pickup: "ready_for_pickup",
    picked_up: "picked_up",
    cancelled: "cancelled"
  }

  belongs_to :creator, class_name: "User"
  belongs_to :reservation
  has_many :reservation_loans

  acts_as_tenant :library

  def reservation_satisfied?
    reservation.date_holds.all? { |dh| dh.satisfied? }
  end
end
