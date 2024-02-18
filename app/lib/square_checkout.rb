class SquareCheckout
  def initialize(access_token:, location_id:, environment: "production", now: Time.current)
    @client = Square::Client.new(access_token: access_token, environment: environment)
    @location_id = location_id
    @now = now
  end

  def checkout_url(amount:, email:, date:, member_id:, return_to:, idempotency_key: random_idempotency_key)
    checkout_response = @client.checkout.create_payment_link(
      body: {
        idempotency_key: idempotency_key,
        pre_populated_data: {
          buyer_email: email
        },
        checkout_options: {
          redirect_url: return_to,
          allow_tipping: false,
          enable_coupon: false,
          enable_loyalty: false,
          accepted_payment_methods: {
            apple_pay: true,
            google_pay: true,
            cash_app_pay: true
          }
        },
        order: {
          reference_id: "#{date.strftime("%Y%m%d")}-#{member_id}",
          location_id: @location_id,

          line_items: [{
            name: "Annual Membership",
            quantity: "1",
            base_price_money: {
              amount: amount.cents,
              currency: "USD"
            }

          }]
        },
        payment_note: "Chicago Tool Library annual membership"
      }
    )
    if checkout_response.success?
      Result.success(checkout_response.body.payment_link[:url])
    else
      Result.failure(checkout_response.errors)
    end
  end

  def fetch_order(order_id:)
    order_response = @client.orders.retrieve_order(order_id: order_id)

    if order_response.success?
      order = order_response.body.order
      amount_money = order[:tenders][0][:amount_money]

      raise "non-USD currency is not supported" unless amount_money[:currency] == "USD"

      amount = Money.new(amount_money[:amount])

      Result.success(amount)
    else
      Result.failure(order_response.errors)
    end
  end

  private

  def random_idempotency_key
    rand(1_000_000_000).to_s
  end
end
