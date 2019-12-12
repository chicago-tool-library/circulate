# Preview all emails at http://localhost:3000/rails/mailers/member_mailer
class GiftPurchaserMailerPreview < ActionMailer::Preview
  def confirmation
    gift_membership = GiftMembership.last!
    GiftPurchaserMailer.with(gift_membership: gift_membership).confirmation
  end
end
