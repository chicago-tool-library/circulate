# Preview all emails at http://localhost:3000/rails/mailers/member_mailer
class MemberMailerPreview < ActionMailer::Preview
  def welcome_message
    MemberMailer.with(member: Member.first, amount: 2500).welcome_message
  end

  def renewal_message
    MemberMailer.with(member: Member.first, amount: 3400).renewal_message
  end

  def membership_reminder
    MemberMailer.with(member: Member.first).membership_reminder
  end

  def only_returned_items
    loan_summaries = LoanSummary.returned.limit(5).includes(item: :borrow_policy).to_a

    MemberMailer.with(member: Member.first, summaries: loan_summaries).loan_summaries
  end

  def overdue_items
    loan_summaries = LoanSummary.overdue.limit(5).includes(item: :borrow_policy).to_a

    MemberMailer.with(member: Member.first, summaries: loan_summaries).overdue_notice
  end

  def due_soon
    tomorrow = Time.current.end_of_day + 1.day
    3.times do
      Loan.create(item: Item.available.order("RANDOM()").first, member: Member.verified.first, due_at: tomorrow, uniquely_numbered: false)
    end

    loan_summaries = LoanSummary.where("due_at BETWEEN ? AND ?", tomorrow.beginning_of_day.utc, tomorrow.utc).limit(5).includes(item: :borrow_policy).to_a

    first_item = loan_summaries.first.item
    Hold.create!(item: first_item, member: Member.second, creator: User.first)

    MemberMailer.with(member: Member.first, summaries: loan_summaries).return_reminder
  end

  def items_on_hold
    loan_summaries = LoanSummary.where("due_at > ?", Time.current + 1.day).limit(5).includes(item: :borrow_policy).to_a

    first_item = loan_summaries.first.item
    Hold.create!(item: first_item, member: Member.second, creator: User.first)
    loan_summaries.first.latest_loan = Loan.new(created_at: Time.current)

    MemberMailer.with(member: Member.first, summaries: loan_summaries).loan_summaries
  end

  def membership_renewal_reminder
    MemberMailer.with(member: Member.first).membership_renewal_reminder
  end

  def staff_daily_renewal_requests
    tomorrow = Time.current.end_of_day + 1.day
    3.times do
      loan = Loan.create!(item: Item.available.order("RANDOM()").first, member: Member.verified.first, due_at: tomorrow, uniquely_numbered: false)
      RenewalRequest.create!(loan: loan)
    end

    renewal_requests = RenewalRequest.requested.where.not(loan_id: nil).where("created_at >= ?", Time.current.beginning_of_day.utc).includes(loan: [:item, :member]).limit(5)

    MemberMailer.with(member: Member.joins(:user).where(users: {role: :admin}).first, renewal_requests: renewal_requests).staff_daily_renewal_requests
  end
end
