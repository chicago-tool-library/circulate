# Preview all emails at http://localhost:3000/rails/mailers/member_mailer
class MemberMailerPreview < ActionMailer::Preview
  def welcome_message
    MemberMailer.with(member: Member.first, amount: 2500).welcome_message
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

    MemberMailer.with(member: Member.first, summaries: loan_summaries).loan_summaries
  end

  def items_on_hold
    loan_summaries = LoanSummary.where("due_at > ?", Time.current + 1.day).limit(5).includes(item: :borrow_policy).to_a

    first_item = loan_summaries.first.item
    Hold.create!(item: first_item, member: Member.second, creator: User.first)
    loan_summaries.first.latest_loan = Loan.new(created_at: Time.current)

    MemberMailer.with(member: Member.first, summaries: loan_summaries).loan_summaries
  end
end
