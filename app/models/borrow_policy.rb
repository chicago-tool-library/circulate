class BorrowPolicy < ApplicationRecord
  monetize :fine_cents, numericality: {
    greater_than_or_equal_to: 0, less_than_or_equal_to: 10,
  }

  validates :name,
    presence: true, uniqueness: {case_sensitive: false}
  validates_numericality_of :duration,
    only_integer: true, greater_than_or_equal_to: 1, less_than: 365
  validates_numericality_of :fine_period,
    only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 100
  validates :code,
    length: { is: 1 }

  scope :alpha_by_code, -> { order("code ASC") }

  def self.default
    where(default: true).first
  end

  after_save :make_only_default

  private

  def make_only_default
    if default
      self.class.where("id != ?", id).update_all(default: false)
    end
  end
end
