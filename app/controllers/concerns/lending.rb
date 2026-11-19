module Lending
  private

  def create_loan(item, member, now: Time.current)
    loan = Loan.lend(item, to: member, now: now)
    loan.transaction do
      if loan.save && item.borrow_policy.consumable? && return_loan(loan, now: now)
        item.decrement_quantity
      end
      loan
    end
  end

  # Pass the appointment when the hold is being checked out as part of that
  # appointment. Otherwise the hold is leaving the library some other way (a
  # walk-in, the member's holds page), so take it off any appointment the member
  # booked for a later day, or that appointment keeps promising an item the
  # member already has.
  def create_loan_from_hold(hold, now: Time.current, appointment: nil)
    hold.transaction do
      create_loan(hold.item, hold.member, now: now).tap do |loan|
        next unless loan.persisted?

        hold.update!(loan: loan, ended_at: now)
        upcoming = hold.appointment
        if upcoming && upcoming != appointment && upcoming.starts_at > now.end_of_day
          hold.remove_from_appointment!
        end
      end
    end
  end

  # Lends an item to a member from the checkout screen, respecting the hold line.
  #
  # If the item is sitting on the shelf for someone else's ready hold, staff
  # can't lend it by default: the loan comes back unsaved with an error. With
  # over_ready_hold, staff are deliberately lending it anyway. The other
  # member's hold goes back to waiting in its same place in line, comes off any
  # appointment they booked, and they're told what happened.
  #
  # If the member has their own hold on the item, the loan fulfils it.
  def lend_to_member(item, member, over_ready_hold: false, now: Time.current)
    ready_hold = item.ready_hold_for_someone_other_than(member)

    if ready_hold && !over_ready_hold
      return Loan.lend(item, to: member, now:).tap do |loan|
        loan.errors.add(:item_id, "is ready for pickup by member ##{ready_hold.member.number}")
      end
    end

    bumped = []
    loan = nil
    Loan.transaction do
      if ready_hold
        appointment_starts_at = ready_hold.appointment&.starts_at
        appointment_change = ready_hold.return_to_line!(now)
        bumped << [ready_hold, appointment_change && appointment_starts_at, appointment_change]
      end

      own_hold = member.active_holds.find_by(item:)
      loan = own_hold ? create_loan_from_hold(own_hold, now:) : create_loan(item, member, now:)
      raise ActiveRecord::Rollback unless loan.persisted?
    end

    if loan.persisted?
      bumped.each { |hold, starts_at, change| HoldReturnedToLineJob.perform_later(hold.id, starts_at, change) }
    end
    loan
  end

  def return_loan(loan, now: Time.current)
    success = false
    policy = loan.item.borrow_policy

    loan.transaction do
      next unless loan.update(ended_at: now)

      amount = FineCalculator.new.amount(fine: policy.fine, period: policy.fine_period, due_at: loan.due_at, returned_at: loan.ended_at)
      if amount > 0
        Adjustment.create!(member_id: loan.member_id, adjustable: loan, amount: amount * -1, kind: "fine")
      end

      # reject any renewal requests to avoid confusion
      loan.renewal_requests.requested.each do |renewal_request|
        renewal_request.update!(status: "rejected")
      end

      success = true
    end

    success ? loan : false
  end

  def undo_loan(loan)
    return false if loan.renewal?
    loan.transaction do
      loan.destroy
      if loan.item.borrow_policy.consumable?
        loan.item.increment_quantity
      end
    end
    true
  end

  def restore_loan(loan)
    loan.update(ended_at: nil)
  end

  def renew_loan(loan, now: Time.current)
    success = false
    period_start_date = [loan.due_at, now.end_of_day].max
    new_loan = Loan.new(
      member_id: loan.member_id,
      item_id: loan.item_id,
      initial_loan_id: loan.initial_loan_id || loan.id,
      renewal_count: loan.renewal_count + 1,
      due_at: Event.next_open_day(period_start_date + loan.item.borrow_policy.duration.days).end_of_day,
      uniquely_numbered: loan.uniquely_numbered,
      created_at: now
    )

    loan.transaction do
      next unless return_loan(loan, now: now)
      new_loan.save!

      # update any appointments connected with the old loan
      AppointmentLoan.where(loan_id: loan).update_all(loan_id: new_loan.id)

      success = true
    end

    success ? new_loan : false
  end

  def undo_loan_renewal(loan)
    success = false
    target = nil

    loan.transaction do
      next unless loan.destroy

      target = if loan.renewal_count > 1
        loan.initial_loan.renewals.order(created_at: :desc).where.not(id: loan.id).first
      else
        loan.initial_loan
      end
      target.update!(ended_at: nil)

      # update any appointments connected with the reverted loan
      AppointmentLoan.where(loan_id: loan).update_all(loan_id: target.id)

      success = true
    end

    success ? target : false
  end
end
