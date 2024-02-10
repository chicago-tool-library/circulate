class ItemPool < ApplicationRecord
  belongs_to :creator, class_name: "User"
  has_many :reservable_items
  has_many :date_holds

  def max_available_between(starts, ends, ignored_reservation_id: nil)
    total_items = reservable_items.count
    total_booked = date_holds.overlapping(starts, ends).where.not(reservation_id: ignored_reservation_id).sum(:quantity)
    total_items - total_booked
  end
end
