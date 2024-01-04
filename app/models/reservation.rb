class Reservation < ApplicationRecord
  validates :name, presence: true
  validates :started_at, presence: true
  validates :ended_at, presence: true

  has_many :date_holds
  has_many :reservable_items, through: :date_holds
end
