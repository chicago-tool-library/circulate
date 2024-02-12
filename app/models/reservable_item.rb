class ReservableItem < ApplicationRecord
  belongs_to :item_pool

  validates :name, presence: true
end
