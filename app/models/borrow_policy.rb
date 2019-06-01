class BorrowPolicy < ApplicationRecord
  monetize :fine_cents, numericality: {
    greater_than_or_equal_to: 0, less_than_or_equal_to: 10
  }

  validates :name, 
    presence: true, uniqueness: { case_sensitive: false }
  validates_numericality_of :duration,
    only_integer: true, greater_than_or_equal_to: 1, less_than: 365
  validates_numericality_of :fine_period,
    only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 100

  def self.default
    where(name: "Default").first
  end
end
