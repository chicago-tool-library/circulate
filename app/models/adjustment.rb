class Adjustment < ApplicationRecord
  monetize :amount_cents

  enum payment_source: {
    cash: "cash",
    square: "square",
    forgiveness: "forgiveness"
  }

  enum kind: {
    fine: "fine",
    membership: "membership",
    donation: "donation",
    payment: "payment"
  }

  belongs_to :adjustable, polymorphic: true, optional: true
  belongs_to :member

  # validates_presence_of :square_transaction_id, if: ->(a) { a.square? }
  validates :payment_source, inclusion: {in: payment_sources, if: ->(a) { a.payment? }}
  validates :payment_source, absence: {unless: ->(a) { a.payment? }}
  validates :kind, inclusion: {in: kinds}

  def self.record_membership(membership, amount)
    membership.member.adjustments.create!(amount: -amount, adjustable: membership, kind: "membership")
  end

  def self.record_member_payment(member, amount, source, square_transaction_id = nil)
    donation_amount = amount + member.account_balance
    adjustments = []
    if donation_amount > 0
      adjustments << member.adjustments.create!(amount: -donation_amount, kind: "donation")
    end
    adjustments << member.adjustments.create!(
      payment_source: source,
      amount: amount,
      kind: "payment",
      square_transaction_id: square_transaction_id
    )
    adjustments
  end
end
