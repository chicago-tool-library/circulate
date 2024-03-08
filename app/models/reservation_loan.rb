class ReservationLoan < ApplicationRecord
  belongs_to :reservable_item, required: false
  belongs_to :date_hold

  validate :date_hold_quantity_not_exceeded
  validates :reservable_item_id, uniqueness: {scope: :date_hold_id, message: "has already been added"}

  private

  def date_hold_quantity_not_exceeded
    return unless date_hold
    return unless date_hold.item_pool.uniquely_numbered?

    if date_hold.reservation_loans.count >= date_hold.quantity
      errors.add(:reservable_item_id, "only #{date_hold.quantity} #{date_hold.item_pool.name} are required")
    end
  end
end
