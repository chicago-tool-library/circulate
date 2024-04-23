# A ReservableItem is an item that can be checked out while fulfilling a Reservation via a ReservationLoan.
class ReservableItem < ApplicationRecord
  include ItemStatuses
  include ItemNumbering

  belongs_to :creator, class_name: "User"
  belongs_to :item_pool, counter_cache: true
  has_many :reservation_loans

  validates :name, presence: true

  acts_as_tenant :library
end
