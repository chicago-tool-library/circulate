class ReservableItem < ApplicationRecord
  validates :name, presence: true
end
