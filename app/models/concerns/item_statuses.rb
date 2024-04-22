require "active_support/concern"

module ItemStatuses
  extend ActiveSupport::Concern

  STATUS_NAMES = {
    "pending" => "Pending",
    "active" => "Active",
    "maintenance" => "Maintenance",
    "retired" => "Retired"
  }

  STATUS_DESCRIPTIONS = {
    "pending" => "just acquired; not ready to loan",
    "active" => "available to loan",
    "maintenance" => "undergoing maintenance; do not loan",
    "retired" => "no longer part of our inventory"
  }

  included do
    enum status: {
      pending: "pending",
      active: "active",
      maintenance: "maintenance",
      retired: "retired"
    }

    validates :status, inclusion: {in: statuses.keys}
  end
end
