class MembershipPaymentForm
  include ActiveModel::Model

  attr_accessor :amount_dollars

  validates_numericality_of :amount_dollars,
    greater_than_or_equal_to: 5, less_than_or_equal_to: 500

  def amount
    Money.new(amount_dollars.to_i * 100)
  end
end
