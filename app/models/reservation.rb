# A Reservation represents a request to borrow a set items from one or more ItemPools for a duration of time.
class Reservation < ApplicationRecord
  enum status: {
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
  }

  has_many :reservation_holds
  has_many :reservation_loans
  has_many :item_pools, through: :reservation_holds
  belongs_to :reviewer, class_name: "User", required: false

  accepts_nested_attributes_for :reservation_holds, allow_destroy: true

  validates :name, presence: true
  validates :started_at, presence: true
  validates :ended_at, presence: true
  validates :status, inclusion: {in: Reservation.statuses.keys}
  validates_associated :reservation_holds

  before_validation :move_ended_at_to_end_of_day

  scope :by_start_date, -> { order(started_at: :asc) }

  acts_as_tenant :library

  def item_quantity
    reservation_holds.sum(&:quantity)
  end

  def satisfied?
    reservation_holds.all? { |rh| rh.satisfied? }
  end

  # temporary
  def pickup
    self
  end

  private

  def move_ended_at_to_end_of_day
    write_attribute :ended_at, ended_at.end_of_day if ended_at.present?
  end
end
