# These are helpers that make it simpler to express in tests when you need open
# days for the library to be scheduled in relation to test objects. Calculating
# due_at for loans and renewals looks for future Events and will blow up if it
# doesn't find them.
module OpenDaysHelper
  def create_open_day_for_loan(item, now: Time.current)
    create(:appointment_slot_event, start: now.middle_of_day + item.borrow_policy.duration.days)
  end

  def create_open_day_for_renewal(loan)
    create(:appointment_slot_event, start: loan.due_at.middle_of_day + loan.item.borrow_policy.duration.days)
  end
end
