# These are helpers that make it simpler to express in tests when you need open
# days for the library to be scheduled in relation to test objects. Calculating
# due_at for loans and renewals looks for future Events and will blow up if it
# doesn't find them.
module OpenDaysHelper
  # Creates an open day on the due date for the specified item, so a loan can be created for it.
  def create_open_day_for_loan(item, now: Time.current)
    create(:appointment_slot_event, start: now.middle_of_day + item.borrow_policy.duration.days)
  end

  # Creates an open day on the renewal date for the specified loan, so a renewal will be successful.
  def create_open_day_for_renewal(loan, now: Time.current)
    period_start_date = [loan.due_at, now.end_of_day].max
    create(:appointment_slot_event, start: (period_start_date + loan.item.borrow_policy.duration.days).middle_of_day)
  end
end
