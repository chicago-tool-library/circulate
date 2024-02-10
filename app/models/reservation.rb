class Reservation < ApplicationRecord
  enum status: {
    pending: "pending",
    requested: "requested",
    approved: "approved",
    rejected: "rejected"
  }

  validates :name, presence: true
  validates :started_at, presence: true
  validates :ended_at, presence: true
  validates :status, inclusion: {in: Reservation.statuses.keys}

  has_many :date_holds
  has_many :item_pools, through: :date_holds
  belongs_to :reviewer, class_name: "User", required: false
  has_one :pickup

  accepts_nested_attributes_for :date_holds, allow_destroy: true
  validates_associated :date_holds

  private
end
