# frozen_string_literal: true

class FineCalculator
  def self.for_overdue_loan(loan, now)
    borrow_policy = loan.item.borrow_policy
    new.amount(fine: borrow_policy.fine, period: borrow_policy.fine_period, due_at: loan.due_at, returned_at: now)
  end

  def amount(fine:, period:, due_at:, returned_at:)
    if returned_at <= due_at
      Money.new(0)
    else
      periods = (returned_at - due_at) / period.days.to_f
      Money.new(periods.ceil * fine)
    end
  end
end
