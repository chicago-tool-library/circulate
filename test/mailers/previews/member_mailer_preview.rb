# Preview all emails at http://localhost:3000/rails/mailers/member_mailer
class MemberMailerPreview < ActionMailer::Preview
  def welcome_message
    MemberMailer.with(member: Member.first).welcome_message
  end
end
