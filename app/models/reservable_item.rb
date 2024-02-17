class ReservableItem < ApplicationRecord
  belongs_to :item_pool, counter_cache: true

  validates :name, presence: true
end
