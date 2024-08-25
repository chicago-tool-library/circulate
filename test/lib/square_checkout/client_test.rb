require "test_helper"

module SquareCheckout
  class ClientTest < ActiveSupport::TestCase
    test "generates a checkout URL" do
      member = create(:member)
      amount = Money.new(4200)

      mock_body_payment_link = Minitest::Mock.new
      mock_body_payment_link.expect :[], "http://squareup.com/checkout", [:url]

      mock_body = Minitest::Mock.new
      mock_body.expect :payment_link, mock_body_payment_link

      mock_response = Minitest::Mock.new
      mock_response.expect :success?, true
      mock_response.expect :body, mock_body

      mock_checkout = Minitest::Mock.new
      mock_checkout.expect(:create_payment_link, mock_response,
        body: {
          idempotency_key: "test",
          pre_populated_data: {
            buyer_email: member.email
          },
          checkout_options: {
            redirect_url: "http://example.com/callback",
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
            reference_id: "20240101-#{member.id}",
            location_id: "SQ_LOCATION_ID",
            line_items: [{
              name: "Annual Membership",
              quantity: "1",
              base_price_money: {
                amount: amount.cents,
                currency: "USD"
              }
            }],
            metadata: {
              member_id: member.id.to_s,
              created_by: "circulate"
            }
          },
          payment_note: "Chicago Tool Library annual membership"
        })

      mock_client = Minitest::Mock.new
      mock_client.expect :checkout, mock_checkout

      Square::Client.stub :new, mock_client do
        checkout = SquareCheckout::Client.new(access_token: "SQ_ACCESS_TOKEN", location_id: "SQ_LOCATION_ID")
        result = checkout.checkout_url(
          amount: amount,
          email: member.email,
          date: Time.zone.local(2024, 1, 1),
          member_id: member.id,
          return_to: "http://example.com/callback",
          idempotency_key: "test"
        )

        assert result.success?
        assert_equal "http://squareup.com/checkout", result.value
      end

      assert_mock mock_response
      assert_mock mock_client
      assert_mock mock_checkout
      assert_mock mock_body
      assert_mock mock_body_payment_link
    end

    test "handles not generating a checkout URL" do
      member = create(:member)
      form = MembershipPaymentForm.new(amount_dollars: 42)

      mock_response = Minitest::Mock.new
      mock_response.expect :success?, false
      mock_response.expect :errors, "ERRORS"

      # No need to assert the specifics of what params create_payment_link is called with
      # as we do that in the successful case above.
      mock_checkout = Minitest::Mock.new
      mock_checkout.expect :create_payment_link, mock_response, body: Hash

      mock_client = Minitest::Mock.new
      mock_client.expect :checkout, mock_checkout

      Square::Client.stub :new, mock_client do
        checkout = SquareCheckout::Client.new(access_token: "SQ_ACCESS_TOKEN", location_id: "SQ_LOCATION_ID")
        result = checkout.checkout_url(
          amount: form.amount,
          email: member.email,
          return_to: "http://example.com/callback",
          member_id: member.id,
          date: Time.zone.local(2024, 1, 1),
          idempotency_key: "test"
        )

        assert result.failure?
        assert_instance_of SquareCheckout::SquareError, result.error
      end

      assert_mock mock_response
      assert_mock mock_client
    end

    test "handles a successful charge" do
      order_payload = {id: "XfTpzcdd4r55sZSxyJhsjrJovb4F",
                       location_id: "X9QSBEAF8RK29",
                       line_items: [{uid: "mif7dF4aXAOweVBR1kMVIC",
                                     quantity: "1",
                                     name: "Annual Membership",
                                     base_price_money: {amount: 4200, currency: "USD"},
                                     gross_sales_money: {amount: 4200, currency: "USD"},
                                     total_tax_money: {amount: 0, currency: "USD"},
                                     total_discount_money: {amount: 0, currency: "USD"},
                                     total_money: {amount: 4200, currency: "USD"},
                                     variation_total_price_money: {amount: 4200, currency: "USD"},
                                     item_type: "ITEM",
                                     total_service_charge_money: {amount: 0, currency: "USD"}}],
                       fulfillments: [{uid: "AwGQocvjXJAyzG22nhH6eC", type: "DIGITAL", state: "PROPOSED"}],
                       metadata: {member_id: "21", created_by: "circulate"},
                       created_at: "2024-02-07T05:09:03.336Z",
                       updated_at: "2024-06-26T04:19:12.846Z",
                       state: "OPEN",
                       version: 8,
                       reference_id: "20240206-69",
                       total_tax_money: {amount: 0, currency: "USD"},
                       total_discount_money: {amount: 0, currency: "USD"},
                       total_tip_money: {amount: 0, currency: "USD"},
                       total_money: {amount: 4200, currency: "USD"},
                       tenders: [{id: "hSD79AU9DDy6v8ehelHi9XM0hXLZY",
                                  location_id: "X9QSBEAF8RK29",
                                  transaction_id: "XfTpzcdd4r55sZSxyJhsjrJovb4F",
                                  created_at: "2024-02-07T05:09:13Z",
                                  note: "Chicago Tool Library annual membership",
                                  amount_money: {amount: 4200, currency: "USD"},
                                  type: "OTHER",
                                  payment_id: "hSD79AU9DDy6v8ehelHi9XM0hXLZY"}],
                       total_service_charge_money: {amount: 0, currency: "USD"},
                       net_amounts: {total_money: {amount: 4200, currency: "USD"},
                                     tax_money: {amount: 0, currency: "USD"},
                                     discount_money: {amount: 0, currency: "USD"},
                                     tip_money: {amount: 0, currency: "USD"},
                                     service_charge_money: {amount: 0, currency: "USD"}},
                       source: {name: "Sandbox for sq0idp-IPM-pOTUhlsIdaQnJ5loXw"},
                       net_amount_due_money: {amount: 0, currency: "USD"}}

      mock_body = Minitest::Mock.new
      mock_body.expect :order, order_payload

      mock_response = Minitest::Mock.new
      mock_response.expect :success?, true
      mock_response.expect :body, mock_body

      mock_orders = Minitest::Mock.new
      mock_orders.expect(:retrieve_order, mock_response, order_id: "order-12345")

      mock_client = Minitest::Mock.new
      mock_client.expect :orders, mock_orders

      Square::Client.stub :new, mock_client do
        checkout = SquareCheckout::Client.new(access_token: "SQ_ACCESS_TOKEN", location_id: "SQ_LOCATION_ID")
        fetch_order = checkout.fetch_order(order_id: "order-12345")

        assert fetch_order.success?
        order = fetch_order.value

        assert_equal Money.new(4200), order.amount
      end

      assert_mock mock_response
      assert_mock mock_client
      assert_mock mock_orders
      assert_mock mock_body
    end

    test "handles not finding an order" do # handles 404 and 429
      mock_response = Minitest::Mock.new
      mock_response.expect :success?, false
      mock_response.expect :errors, "ERRORS"

      mock_orders = Minitest::Mock.new
      mock_orders.expect(:retrieve_order, mock_response, order_id: "order-12345")

      mock_client = Minitest::Mock.new
      mock_client.expect :orders, mock_orders

      Square::Client.stub :new, mock_client do
        checkout = SquareCheckout::Client.new(access_token: "SQ_ACCESS_TOKEN", location_id: "SQ_LOCATION_ID")
        fetch_order = checkout.fetch_order(order_id: "order-12345")

        assert fetch_order.failure?
        assert_instance_of SquareCheckout::SquareError, fetch_order.error
      end

      assert_mock mock_response
      assert_mock mock_client
      assert_mock mock_orders
    end

    test "generates a checkout URL in the sandbox environment", :remote do
      form = MembershipPaymentForm.new(amount_dollars: 42)

      checkout = SquareCheckout::Client.new(access_token: ENV["SQUARE_ACCESS_TOKEN"], location_id: ENV["SQUARE_LOCATION_ID"], environment: "sandbox")
      result = checkout.checkout_url(
        amount: form.amount,
        email: "example@chicagotoollibrary.org",
        return_to: "http://example.com/callback",
        member_id: 1234,
        date: Time.zone.local(2025, 1, 1)
      )

      assert_nil result.error
      assert result.success?
    end

    test "fetches an order from the sandbox environment", :remote do
      checkout = SquareCheckout::Client.new(access_token: ENV["SQUARE_ACCESS_TOKEN"], location_id: ENV["SQUARE_LOCATION_ID"], environment: "sandbox")
      result = checkout.fetch_order(order_id: "jnS4zCQGfiqRO1pXSRFZZnyltZ4F")

      assert_nil result.error
      assert result.success?
    end
  end
end
