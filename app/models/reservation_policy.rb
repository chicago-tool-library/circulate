class ReservationPolicy < ApplicationRecord
  belongs_to :library, required: true
  has_many :item_pools, dependent: :nullify

  acts_as_tenant :library

  validates :name, presence: true, uniqueness: true
  validates :maximum_duration, presence: true
  validates :minimum_start_distance, presence: true
  validates :maximum_start_distance, presence: true
  validates_numericality_of :maximum_duration, only_integer: true, greater_than: 0
  validates_numericality_of :minimum_start_distance, only_integer: true, greater_than_or_equal_to: 0
  validates_numericality_of :maximum_start_distance, only_integer: true, greater_than: 0
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
