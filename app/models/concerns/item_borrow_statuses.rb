require "active_support/concern"

module ItemBorrowStatuses
  extend ActiveSupport::Concern

  # Where an item is in the borrowing cycle. This is independent of the item's
  # status: a retired item can still be checked out, and a pending item is
  # available in the sense that nobody has it.
  BORROW_STATUS_NAMES = {
    "available" => "Available",
    "on_hold" => "On Hold",
    "checked_out" => "Checked Out",
    "overdue" => "Overdue"
  }

  BORROW_STATUS_CSS_CLASSES = {
    "available" => "label-success",
    "on_hold" => "label-warning",
    "checked_out" => "label-warning",
    "overdue" => "label-error"
  }

  # Items are ordered in search results by how borrowable they are: active
  # items first, ordered by borrow status, then everything a member can't
  # borrow right now.
  BORROW_STATUS_SEARCH_PRIORITIES = {
    "available" => 1,
    "on_hold" => 2,
    "checked_out" => 3,
    "overdue" => 4
  }

  MAINTENANCE_SEARCH_PRIORITY = 5
  UNBORROWABLE_SEARCH_PRIORITY = 6

  def borrow_status
    if checked_out_exclusive_loan
      overdue? ? "overdue" : "checked_out"
    elsif borrow_policy.uniquely_numbered? && active_holds.size > 0
      "on_hold"
    else
      "available"
    end
  end

  def borrow_status_name
    BORROW_STATUS_NAMES[borrow_status]
  end

  class_methods do
    # SQL equivalent of #borrow_status, for ordering search results. Expects the
    # relation to join loans, borrow_policies, and the active_hold_counts CTE.
    def borrow_status_search_priority
      Arel::Nodes::Case.new
        .when(Loan.arel_table[:id].not_eq(nil)).then(
          Arel::Nodes::Case.new
            .when(Loan.arel_table[:due_at].lt(Time.current))
            .then(BORROW_STATUS_SEARCH_PRIORITIES["overdue"])
            .else(BORROW_STATUS_SEARCH_PRIORITIES["checked_out"])
        )
        .when(
          Arel::Nodes::And.new([
            BorrowPolicy.arel_table[:uniquely_numbered],
            Arel::Nodes::SqlLiteral.new("active_hold_counts.item_id IS NOT NULL")
          ])
        ).then(BORROW_STATUS_SEARCH_PRIORITIES["on_hold"])
        .else(BORROW_STATUS_SEARCH_PRIORITIES["available"])
    end

    def search_priority
      Arel::Nodes::Case.new(arel_table[:status])
        .when("active").then(borrow_status_search_priority)
        .when("maintenance").then(MAINTENANCE_SEARCH_PRIORITY)
        .else(UNBORROWABLE_SEARCH_PRIORITY)
        .as("search_priority")
    end
  end
end
