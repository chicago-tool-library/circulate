# A ReservableItem is an item that can be checked out while fulfilling a Reservation via a ReservationLoan.
class ReservableItem < ApplicationRecord
  include ItemStatuses
  include ItemNumbering

  belongs_to :creator, class_name: "User"
  belongs_to :item_pool, counter_cache: true
  has_many :reservation_loans
  has_one_attached :image

  store_accessor :myturn_metadata,
    :image_url, :dimensions, :weight, :item_type, :supplier

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

  def import_myturn_image
    return if myturn_metadata["image_url"].blank?

    url = URI.parse(myturn_metadata["image_url"])
    filename = File.basename(url.path)
    downloaded_image = url.open
    image.attach(io: downloaded_image, filename:)
  end
end
