class SquarePaymentJob < ApplicationJob
  class MetadataMissingError < StandardError; end

  class OrderLookupError < StandardError; end

  def perform(order_id:)
    existing_adjustment = Adjustment.find_by(square_transaction_id: order_id)
    if existing_adjustment
      Rails.logger.info("Adjustment already exists for order #{order_id}, skipping.")
      return
    end

    fetch_order = square_checkout.fetch_order(order_id: order_id)

    if fetch_order.failure?
      raise OrderLookupError.new("could not find order with id #{order_id}: #{fetch_order.error}")
    end
    order = fetch_order.value

    unless order.created_by_circulate?
      # This order is not an automated membership payment.
      return
    end

    member_id = order.member_id

    if member_id.nil?
      raise MissingMetadataError.new("no member_id in metadata for order #{order_id}")
    end

    member = Member.find(member_id)

    Membership.create_for_member(member, amount: order.amount, square_transaction_id: order.id, source: "square")
    MemberMailer.with(member: member, amount: order.amount.cents).welcome_message.deliver_later

    result = square_checkout.complete_order(order)
    raise result.error if result.failure?
  end

  private

  def square_checkout
    @square_checkout ||= SquareCheckout::Client.from_env
  end
end
