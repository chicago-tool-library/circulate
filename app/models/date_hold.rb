class DateHold < ApplicationRecord
  belongs_to :reservation
  belongs_to :item_pool

  validate :ensure_quantity_is_available

  # TODO add database constraint
  validates :item_pool_id, uniqueness: {scope: :reservation_id, message: "already added to this reservation"}

  scope :overlapping, ->(starts, ends) { joins(:reservation).where("tsrange(?, ?) && tsrange(reservations.started_at, reservations.ended_at)", starts, ends) }

  private

  def ensure_quantity_is_available
    max_available = item_pool.max_available_between(reservation.started_at, reservation.ended_at, ignored_reservation_id: reservation_id)
    unless quantity <= max_available
      message = (max_available == 0) ? "none available" : "only #{max_available} available"
      errors.add(:quantity, message)
    end
  end
end
