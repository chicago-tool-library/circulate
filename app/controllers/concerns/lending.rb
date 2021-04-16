module Lending
  private

  def return_loan(loan, now: Time.current)
    success = false
    policy = loan.item.borrow_policy

    loan.transaction do
      next unless loan.update(ended_at: now)

      amount = FineCalculator.new.amount(fine: policy.fine, period: policy.fine_period, due_at: loan.due_at, returned_at: loan.ended_at)
      if amount > 0
        Adjustment.create!(member_id: loan.member_id, adjustable: loan, amount: amount * -1, kind: "fine")
      end

      if (hold = loan.item.next_hold)
        hold.start!
        MemberMailer.with(member: hold.member, hold: hold).hold_available.deliver_later
      end
      success = true
    end

    success ? loan : false
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
      due_at: Loan.next_open_day(period_start_date + loan.item.borrow_policy.duration.days),
      uniquely_numbered: loan.uniquely_numbered,
      created_at: now
    )

    loan.transaction do
      next unless return_loan(loan, now: now)
      new_loan.save!
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
      success = true
    end

    success ? target : false
  end
end
