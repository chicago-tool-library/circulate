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

  # Members are shown the borrow status of active items, so these only come up
  # for items that have left circulation. Members normally can't see those at
  # all, but an item saved for later can end up in any status.
  MEMBER_STATUS_NAMES = Hash.new("Unavailable").merge(
    "maintenance" => "In Maintenance"
  ).freeze

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
    "not_returned" => "not returned after being checked out",
    "broken" => "returned in a not working state",
    "used_up" => "used up, worn out, or otherwise consumed",
    "upgraded" => "replaced with a newer or better item"
  }

  def status_name
    STATUS_NAMES[status]
  end

  # The status, plus why the item was retired when we know it
  def full_status_name
    retired_reason ? "#{status_name} (#{retired_reason_name})" : status_name
  end

  def member_status_name
    MEMBER_STATUS_NAMES[status]
  end

  def retired_reason_name
    RETIRED_REASON_NAMES[retired_reason]
  end

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
