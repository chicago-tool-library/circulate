# A ReservationLoan represents that a specific ReservableItem was checked out for a Reservation.
class ReservationLoan < ApplicationRecord
  belongs_to :reservable_item, optional: true
  belongs_to :reservation_hold
  belongs_to :reservation

  validates :reservable_item_id, uniqueness: {scope: :reservation_hold_id, message: "has already been added"}
  validates :quantity, numericality: {only_integer: true, greater_than: 0, allow_nil: true}
  validate :reservation_hold_quantity_not_exceeded
  validate :item_is_available

  acts_as_tenant :library

  scope :pending, -> { where(checked_out_at: nil) }
  scope :checked_out, -> { where.not(checked_out_at: nil).and(where(checked_in_at: nil)) }
  scope :pending_or_checked_out, -> { pending.or(checked_out) }

  private

  def reservation_hold_quantity_not_exceeded
    return unless reservation_hold
    return unless reservation_hold.item_pool.uniquely_numbered?

    if reservation_hold.reservation_loans.where.not(id:).count >= reservation_hold.quantity
      errors.add(:reservable_item_id, "only #{reservation_hold.quantity} #{reservation_hold.item_pool.name} are required")
    end
  end

  def item_is_available
    return unless reservable_item
    return true unless reservation_hold.item_pool.uniquely_numbered?

    # Prevent an item from being attached to more than one reservation at a time
    if reservable_item.reservation_loans.pending_or_checked_out.where.not(id:).any?
      errors.add(:reservable_item_id, "is already assigned to another reservation")
    end
  end
end
