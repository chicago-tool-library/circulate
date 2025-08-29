class StripeCheckout
  def initialize(api_key, environment: "production", now: Time.current)
    @client = Stripe::StripeClient.new(api_key)
    @now = now
  end

  # TODO add user_id:, organization_id:,
  def checkout_url(amount:, email:, return_to:)
    session = @client.v1.checkout.sessions.create({
      customer_email: email,
      line_items: [{
        # TODO set the org levels as products in stripe UI and pass one of those here
        price_data: {
          currency: "USD",
          unit_amount: amount.cents,
          product_data: {
            name: "Annual Membership"
          }
        },
        quantity: 1
      }],

      mode: "payment",
      currency: "USD",
      customer_creation: "always",

      # Allow users to have their payment info prefilled for future purposes
      saved_payment_method_options: {payment_method_save: "enabled"},

      # Save payment info for circulate-created future charges
      payment_intent_data: {setup_future_usage: "off_session"},

      success_url: return_to + "?session_id={CHECKOUT_SESSION_ID}",
      cancel_url: return_to
    })

    Result.success(session.url)
  rescue Stripe::InvalidRequestError => e
    Result.failure(e)
  end

  def fetch_session(session_id:)
    session = @client.v1.checkout.sessions.retrieve(params[:session_id])
    customer = @client.v1.customers.retrieve(session.customer)
    puts session
    puts customer
    binding.irb

    order = order_response.body.order
    amount_money = order[:tenders][0][:amount_money]

    raise "non-USD currency is not supported" unless amount_money[:currency] == "USD"

    amount = Money.new(amount_money[:amount])

    Result.success(amount)
  rescue Stripe::InvalidRequestError => e
    Result.failure(e)
  end

  # private

  # def random_idempotency_key
  #   rand(1_000_000_000).to_s
  # end
end
