class MembershipForm
  include ActiveModel::Model

  attr_reader :with_payment
  attr_reader :start_membership

  PAYMENT_ATTRIBUTES = %w[amount_dollars payment_source]

  delegate(*PAYMENT_ATTRIBUTES, to: :@payment)

  def initialize(member, params = {})
    @member = member
    @payment = Admin::Payment.new(params.slice(*PAYMENT_ATTRIBUTES))

    @with_payment = params.key?("with_payment") ? params["with_payment"] == "true" : true
    @start_membership = params["start_membership"] != "0"
  end

  def errors
    @payment.errors.dup
  end

  def save
    if with_payment
      save_with_payment
    else
      save_without_payment
    end
  end

  private

  def save_with_payment
    @payment.valid? && Membership.create_for_member(@member, amount: @payment.amount, source: @payment.payment_source, start_membership: start_membership)
  end

  def save_without_payment
    Membership.create_for_member(@member, start_membership: start_membership)
  end
end
