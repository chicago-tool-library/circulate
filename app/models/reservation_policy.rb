class ReservationPolicy < ApplicationRecord
  belongs_to :library, optional: false
  has_many :item_pools, dependent: :nullify

  acts_as_tenant :library

  validates :name, presence: true, uniqueness: { scope: :library_id }
  validates :maximum_duration, presence: true
  validates :minimum_start_distance, presence: true
  validates :maximum_start_distance, presence: true
  validates :maximum_duration, numericality: {only_integer: true, greater_than: 0}
  validates :minimum_start_distance, numericality: {only_integer: true, greater_than_or_equal_to: 0}
  validates :maximum_start_distance, numericality: {only_integer: true, greater_than: 0}
  validate :maximum_start_distance_is_greater_than_minimum

  after_save :ensure_only_one_default!

  def self.default_policy
    find_or_initialize_by(default: true) { |policy| policy.name = "System Default" }
  end

  private

  def maximum_start_distance_is_greater_than_minimum
    if minimum_start_distance? && maximum_start_distance? && minimum_start_distance >= maximum_start_distance
      errors.add(:maximum_start_distance, "must be greater than the mininum start distance")
    end
  end

  def ensure_only_one_default!
    self.class.where.not(id:).update_all(default: false) if default?
  end
end
