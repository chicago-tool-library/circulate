class ReservationLoan < ApplicationRecord
  belongs_to :reservable_item, required: false
  belongs_to :date_hold
  belongs_to :pickup

  validate :date_hold_quantity_not_exceeded
  validates :reservable_item_id, uniqueness: {scope: :date_hold_id, message: "has already been added"}
  validate :item_is_available

  acts_as_tenant :library

  scope :pending, -> { where(checked_out_at: nil) }
  scope :checked_out, -> { where.not(checked_out_at: nil).and(where(checked_in_at: nil)) }
  scope :pending_or_checked_out, -> { pending.or(checked_out) }

  def editable?
    checked_out_at.nil?
  end

  private

  def date_hold_quantity_not_exceeded
    return unless date_hold
    return unless date_hold.item_pool.uniquely_numbered?

    if date_hold.reservation_loans.where.not(id:).count >= date_hold.quantity
      errors.add(:reservable_item_id, "only #{date_hold.quantity} #{date_hold.item_pool.name} are required")
    end
  end

  def item_is_available
    return unless reservable_item
    return true unless date_hold.item_pool.uniquely_numbered?

    # Prevent an item from being attached to more than one pickup at a time
    if reservable_item.reservation_loans.pending_or_checked_out.where.not(id:).any?
      errors.add(:reservable_item_id, "is already assigned to another pickup")
    end
  end
end
