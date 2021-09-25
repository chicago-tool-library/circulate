# Preview all emails at http://localhost:3000/rails/mailers/member_mailer
class MemberMailerPreview < ActionMailer::Preview
  include Lending

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
    member = Member.verified.first
    loans = []
    3.times do
      loans << Loan.create(item: Item.available.order("RANDOM()").first, member: member, due_at: tomorrow, uniquely_numbered: false, library: member.library)
    end

    loan_summaries = LoanSummary.where("due_at BETWEEN ? AND ?", tomorrow.beginning_of_day.utc, tomorrow.utc).limit(5).includes(item: :borrow_policy).to_a

    first_item = loan_summaries.first.item
    Hold.create!(item: first_item, member: Member.second, creator: User.first, library: member.library)

    MemberMailer.with(member: member, summaries: loan_summaries).return_reminder
  end

  def items_on_hold
    loan_summaries = LoanSummary.where("due_at > ?", Time.current + 1.day).limit(5).includes(item: :borrow_policy).to_a

    first_item = loan_summaries.first.item
    Hold.create!(item: first_item, member: Member.second, creator: User.first)
    loan_summaries.first.latest_loan = Loan.new(created_at: Time.current)

    MemberMailer.with(member: Member.first, summaries: loan_summaries).loan_summaries
  end

  def hold_available
    first_item = Item.active.first
    hold = Hold.create!(item: first_item, member: Member.second, creator: User.first)

    MemberMailer.with(member: Member.first, hold: hold).hold_available
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

  def renewal_request_approved
    tomorrow = Time.current.end_of_day + 1.day
    loan = Loan.create!(item: Item.available.order("RANDOM()").first, member: Member.verified.first, due_at: tomorrow, uniquely_numbered: false)
    renew_loan(loan)
    renewal_request = RenewalRequest.create!(loan: loan, status: :approved)
    MemberMailer.with(renewal_request: renewal_request).renewal_request_updated
  end

  def renewal_request_rejected
    tomorrow = Time.current.end_of_day + 1.day
    loan = Loan.create!(item: Item.available.order("RANDOM()").first, member: Member.verified.first, due_at: tomorrow, uniquely_numbered: false)
    renewal_request = RenewalRequest.create!(loan: loan, status: :rejected)
    MemberMailer.with(renewal_request: renewal_request).renewal_request_updated
  end
  
  def appointment_confirmation
    member = Member.verified.first
    tomorrow = Time.current + 1.day
    loan = Loan.create!(item: Item.available.order("RANDOM()").first, member: Member.verified.first, due_at: tomorrow, uniquely_numbered: false, library: member.library)
    item = Item.available.order("RANDOM()").first
    appointment = Appointment.new(starts_at: tomorrow, ends_at: tomorrow + 1.hour, member: member)
    appointment.loans << loan
    appointment.save!
    MemberMailer.with(member: member, appointment: appointment).appointment_confirmation
  end
end
