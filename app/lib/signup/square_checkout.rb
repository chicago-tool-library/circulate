module Signup
  class SquareCheckout
    def initialize(access_token:, location_id:)
      @client = Square::Client.new(access_token: access_token)
      @location_id = location_id
    end

    def checkout_url(amount:, email:, member_id:, return_to:)
      checkout_response = @client.checkout.create_checkout(
        location_id: @location_id,
        body: {
          idempotency_key: rand(1_000_000_000).to_s,
          redirect_url: return_to,
          pre_populate_buyer_email: email,
          order: {
            order: {
              location_id: @location_id,
              reference_id: member_id.to_s,
              line_items: [{
                name: "Annual Membership",
                quantity: "1",
                base_price_money: {
                  amount: amount.cents,
                  currency: "USD",
                },
              }],
            },
          },
          note: "Circulate signup payment",
        }
      )
      if checkout_response.success?
        Result.success(checkout_response.body.checkout[:checkout_page_url])
      else
        Result.failure(checkout_response.errors)
      end
    end

    def record_transaction(member:, transaction_id:)
      transaction_response = @client.transactions.retrieve_transaction(
        location_id: @location_id,
        transaction_id: transaction_id,
      )

      if transaction_response.success?
        transaction = transaction_response.body.transaction
        if transaction[:reference_id] != member.id.to_s
          raise "member_id mismatch, current member is #{member.id} but transaction #{transaction[:id]} is for member #{transaction[:reference_id]}"
        end

        amount_money = transaction[:tenders][0][:amount_money]
        raise "non-USD currency is not supported" unless amount_money[:currency] == "USD"

        amount = Money.new(amount_money[:amount])
        member.adjustments.create!(kind: :membership, amount: amount, adjustable: member)
        Result.success(amount)
      else
        Result.failure(transaction_response.errors)
      end
    end
  end
end
