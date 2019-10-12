# Preview all emails at http://localhost:3000/rails/mailers/member_mailer
class MemberMailerPreview < ActionMailer::Preview
  def welcome_message
    MemberMailer.with(member: Member.first, amount: 2500).welcome_message
  end

  def loan_summaries
    MemberMailer.with(member: Member.first, summaries: LoanSummary.limit(5).includes(item: :borrow_policy)).loan_summaries
  end
end
