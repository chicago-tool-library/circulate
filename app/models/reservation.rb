class Reservation < ApplicationRecord
  validates :name, presence: true
  validates :started_at, presence: true
  validates :ended_at, presence: true
  validate :ensure_item_availability

  has_many :date_holds
  has_many :reservable_items, through: :date_holds

  private

  def ensure_item_availability
    reservable_items.each do |item|
      errors.add("reservable_item_ids_#{item.id}", "is not available") unless item.available_between?(started_at, ended_at, allowed_reservation_id: id)
    end
  end
end
