# Preview all emails at http://localhost:3000/rails/mailers/member_mailer
class MemberMailerPreview < ActionMailer::Preview
  def welcome_message
    MemberMailer.with(member: Member.first, amount: 2500).welcome_message
  end

  def loan_summaries
    loan_summaries = LoanSummary.limit(5).includes(item: :borrow_policy).to_a
    loan_summaries << LoanSummary.new(item: Item.first, due_at: 4.hours.ago, renewal_count: 0)
    MemberMailer.with(member: Member.first, summaries: loan_summaries).loan_summaries
  end
end
