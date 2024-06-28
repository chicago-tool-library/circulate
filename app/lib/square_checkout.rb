class SquareCheckout
  class SquareError < StandardError; end

  class FetchedOrder
    def initialize(payload)
      @payload = payload
    end

    def id
      @payload[:id]
    end

    def state
      @payload[:state]
    end

    def version
      @payload[:version]
    end

    def fulfillment
      # Orders created by the Payment link API only have a single fulfillment
      @payload[:fulfillments][0]
    end

    def amount
      @amount ||= extract_amount
    end

    def member_id
      @payload[:metadata][:member_id]&.to_i
    end

    def created_by_circulate?
      @payload[:metadata][:created_by] == "circulate"
    end

    private

    def extract_amount
      amount_money = @payload[:tenders][0][:amount_money]
      raise "non-USD currency is not supported" unless amount_money[:currency] == "USD"
      Money.new(amount_money[:amount])
    end
  end

  def initialize(access_token:, location_id:, environment: "production", now: Time.current)
    bearer_auth_credential = Square::BearerAuthCredentials.new(access_token: access_token)
    @client = Square::Client.new(bearer_auth_credentials: bearer_auth_credential, environment: environment)
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
          }],

          metadata: {
            member_id: member_id.to_s,
            created_by: "circulate"
          }
        },
        payment_note: "Chicago Tool Library annual membership"
      }
    )
    if checkout_response.success?
      Result.success(checkout_response.body.payment_link[:url])
    else
      Result.failure(SquareError.new("failed to create payment link: #{checkout_response.errors}"))
    end
  end

  def complete_order(fetched_order)
    # Square requires that all fulfillments be marked as completed when setting the order's
    # state to completed.
    fulfillment = fetched_order.fulfillment.dup
    fulfillment[:state] = "COMPLETED"

    @client.orders.update_order(
      order_id: fetched_order.id,
      body: {
        order: {
          version: fetched_order.version,
          state: "COMPLETED",
          fulfillments: [fulfillment]
        }
      }
    )
  end

  def fetch_order(order_id:)
    order_response = @client.orders.retrieve_order(order_id: order_id)

    if order_response.success?
      Result.success(FetchedOrder.new(order_response.body.order))
    else
      Result.failure(order_response.errors)
    end
  end

  def self.from_env
    SquareCheckout.new(
      access_token: ENV.fetch("SQUARE_ACCESS_TOKEN"),
      location_id: ENV.fetch("SQUARE_LOCATION_ID"),
      environment: ENV.fetch("SQUARE_ENVIRONMENT")
    )
  end

  private

  def random_idempotency_key
    rand(1_000_000_000).to_s
  end
end
