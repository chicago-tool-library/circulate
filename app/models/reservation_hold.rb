# A ReservationHold represents a hold on an ItemPool for a given date range and quantity.
class ReservationHold < ApplicationRecord
  belongs_to :reservation
  belongs_to :item_pool
  has_many :reservation_loans

  validates :started_at, presence: true
  validates :ended_at, presence: true
  validates :quantity, numericality: {only_integer: true, greater_than: 0}
  validate :ensure_quantity_is_available
  validate :ensure_quantity_covers_existing_loans

  before_validation :fill_dates_from_reservation, unless: :persisted?

  # TODO add database constraint
  validates :item_pool_id, uniqueness: {scope: :reservation_id, message: "already added to this reservation"}

  scope :overlapping, ->(starts, ends) { where("tsrange(?, ?) && tsrange(started_at, ended_at)", starts, ends) }

  acts_as_tenant :library

  # Total number of items that were reserved
  def loaned_quantity
    reservation_loans.sum(:quantity)
  end

  # Do all held items have an associated loaned item?
  def satisfied?
    loaned_quantity == quantity
  end

  # How many more items are needed to satisfy this hold?
  def remaining_quantity
    quantity - loaned_quantity
  end

  def uniquely_numbered?
    item_pool.uniquely_numbered?
  end

  private

  def ensure_quantity_is_available
    max_available = item_pool.max_available_between(started_at, ended_at, ignored_reservation_id: reservation_id, per_reservation: true)
    unless quantity <= max_available
      message = (max_available == 0) ? "none available" : "only #{max_available} available for this reservation"
      errors.add(:quantity, message)
    end
  end

  def ensure_quantity_covers_existing_loans
    required_by_loans = loaned_quantity
    if quantity < required_by_loans
      message = "#{required_by_loans} are required by existing loans"
      errors.add(:quantity, message)
    end
  end

  def fill_dates_from_reservation
    return unless reservation
    self.started_at = reservation.started_at if started_at.nil?
    self.ended_at = reservation.ended_at if ended_at.nil?
  end
end
