class PendingReservationItem < ApplicationRecord
  belongs_to :reservable_item
  belongs_to :reservation
  belongs_to :created_by, class_name: "User"

  validates :reservable_item_id, uniqueness: true
end
