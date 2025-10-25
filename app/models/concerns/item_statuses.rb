require "active_support/concern"

module ItemStatuses
  extend ActiveSupport::Concern

  STATUS_NAMES = {
    "pending" => "Pending",
    "active" => "Active",
    "maintenance" => "Maintenance",
    "missing" => "Missing",
    "retired" => "Retired"
  }

  STATUS_DESCRIPTIONS = {
    "pending" => "just acquired; not ready to loan",
    "active" => "available to loan",
    "maintenance" => "undergoing maintenance; do not loan",
    "missing" => "misplaced; unable to loan",
    "retired" => "no longer part of our inventory"
  }

  RETIRED_REASON_NAMES = {
    "not_returned" => "Not Returned",
    "broken" => "Broken",
    "used_up" => "Used Up",
    "upgraded" => "Upgraded"
  }

  RETIRED_REASON_DESCRIPTIONS = {
    "not_returned" => "Not returned after being checked out",
    "broken" => "Returned in a not working state",
    "used_up" => "Used up, worn out, or otherwise consumed",
    "upgraded" => "Replaced with a newer or better item"
  }

  included do
    enum :status, {
      pending: "pending",
      active: "active",
      maintenance: "maintenance",
      missing: "missing",
      retired: "retired"
    }

    enum :retired_reason, {
      not_returned: "not_returned",
      broken: "broken",
      upgraded: "upgraded",
      used_up: "used_up"
    }

    validates :status, inclusion: {in: statuses.keys}
    validates :retired_reason, inclusion: {in: retired_reasons.keys}, if: ->(i) { i.status == "retired" }
    before_validation :clear_retired_reason_if_needed

    private

    def clear_retired_reason_if_needed
      if status != "retired"
        self.retired_reason = nil
      end
    end
  end
end
