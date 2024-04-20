class ReservableItem < ApplicationRecord
  belongs_to :creator, class_name: "User"
  belongs_to :item_pool, counter_cache: true
  has_many :reservation_loans

  validates :name, presence: true

  acts_as_tenant :library
end
