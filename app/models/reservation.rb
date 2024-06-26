# A Reservation represents a request to borrow a set items from one or more ItemPools for a duration of time.
class Reservation < ApplicationRecord
  enum :status, {
    pending: "pending",       # still being edited by the borrower
    requested: "requested",   # waiting for a review from staff
    approved: "approved",     # staff has approved this reservation
    rejected: "rejected",     # staff has rejected this reservation
    obsolete: "obsolete",     # replaced by a newer version of the reservation
    building: "building",     # being pulled from shelves by staff
    ready: "ready",           # ready for pickup
    borrowed: "borrowed",     # picked up from library
    returned: "returned",     # items returned
    unresolved: "unresolved", # loan complete but requires staff intervention
    cancelled: "cancelled"    # reservation cancelled
  }, instance_methods: false, validate: true

  has_many :reservation_holds
  has_many :reservation_loans
  has_many :item_pools, through: :reservation_holds
  has_many :reservation_policies, through: :item_pools
  belongs_to :reviewer, class_name: "User", required: false

  accepts_nested_attributes_for :reservation_holds, allow_destroy: true

  validates :name, presence: true
  validates :started_at, presence: true
  validates :ended_at, presence: true
  validates_associated :reservation_holds

  before_validation :move_ended_at_to_end_of_day
  before_validation :set_initial_status, on: :initialize
  after_find :restore_manager
  after_initialize :restore_manager
  validate :validate_reservation_dates

  scope :by_start_date, -> { order(started_at: :asc) }

  scope :by_start_date, -> { order(started_at: :asc) }

  acts_as_tenant :library

  def item_quantity
    reservation_holds.sum(&:quantity)
  end

  def satisfied?
    reservation_holds.all? { |rh| rh.satisfied? }
  end

  def manager
    @manager ||= ReservationStateMachine.new(self)
  end

  private

  def set_initial_status
    self.status = state.current
  end

  def restore_manager
    manager.restore!(status.to_sym) if status.present?
  end

  def move_ended_at_to_end_of_day
    write_attribute :ended_at, ended_at.end_of_day if ended_at.present?
  end

  def validate_reservation_dates
    errors.add(:ended_at, "end date must be after the start date") if started_at.present? && ended_at.present? && started_at.to_date >= ended_at.to_date
  end
end
