class ReservableItem < ApplicationRecord
  has_many :date_holds

  validates :name, presence: true

  def available_between?(starts, ends, allowed_reservation_id: nil)
    # Allowed reservation is to handle when we're validating reservations that are being updated
    !date_holds.overlapping(starts, ends).where.not(reservation_id: allowed_reservation_id).exists?
  end
end
