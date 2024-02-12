class Reservation < ApplicationRecord
  enum status: {
    pending: "pending",
    requested: "requested",
    approved: "approved",
    rejected: "rejected"
  }

  has_many :date_holds
  has_many :item_pools, through: :date_holds
  belongs_to :reviewer, class_name: "User", required: false
  has_one :pickup

  accepts_nested_attributes_for :date_holds, allow_destroy: true

  validates :name, presence: true
  validates :started_at, presence: true
  validates :ended_at, presence: true
  validates :status, inclusion: {in: Reservation.statuses.keys}
  validates_associated :date_holds

  before_validation :move_ended_at_to_end_of_day

  private

  def move_ended_at_to_end_of_day
    write_attribute :ended_at, ended_at.end_of_day if ended_at.present?
  end
end
