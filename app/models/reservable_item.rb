# A ReservableItem is an item that can be checked out while fulfilling a Reservation via a ReservationLoan.
class ReservableItem < ApplicationRecord
  include ItemStatuses
  include ItemNumbering

  belongs_to :creator, class_name: "User"
  belongs_to :item_pool, counter_cache: true
  has_many :reservation_loans
  has_one_attached :image

  enum :power_source, {
    solar: "solar",
    gas: "gas",
    air: "air",
    electric_corded: "electric (corded)",
    electric_battery: "electric (battery)"
  }

  validates :power_source, inclusion: {in: power_sources.keys}, allow_blank: true

  acts_as_tenant :library

  monetize :purchase_price_cents,
    allow_nil: true,
    disable_validation: true
end
