# A ReservationHold represents a hold on an ItemPool for a given date range and quantity.
class ReservationHold < ApplicationRecord
  belongs_to :reservation
  belongs_to :item_pool
  has_many :reservation_loans

  validates :started_at, presence: true
  validates :ended_at, presence: true
  validates :quantity, numericality: {only_integer: true, greater_than: 0}
  validate :ensure_quantity_is_available

  before_validation :fill_dates_from_reservation, unless: :persisted?

  # TODO add database constraint
  validates :item_pool_id, uniqueness: {scope: :reservation_id, message: "already added to this reservation"}

  scope :overlapping, ->(starts, ends) { where("tsrange(?, ?) && tsrange(started_at, ended_at)", starts, ends) }

  acts_as_tenant :library

  # Total number of items that were reserved
  def loaned_quantity
    if item_pool.uniquely_numbered?
      reservation_loans.size
    else
      reservation_loans.pluck(:quantity).sum
    end
  end

  # Do all held items have an associated loaned item?
  def satisfied?
    loaned_quantity == quantity
  end

  # How many more items are needed to satisfy this hold?
  def remaining_quantity
    quantity - loaned_quantity
  end

  private

  def ensure_quantity_is_available
    max_available = item_pool.max_available_between(started_at, ended_at, ignored_reservation_id: reservation_id)
    unless quantity <= max_available
      message = (max_available == 0) ? "none available" : "only #{max_available} available"
      errors.add(:quantity, message)
    end
  end

  def fill_dates_from_reservation
    return unless reservation
    self.started_at = reservation.started_at if started_at.nil?
    self.ended_at = reservation.ended_at if ended_at.nil?
  end
end
