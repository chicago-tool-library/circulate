require "test_helper"

class SquareCheckoutTest < ActiveSupport::TestCase
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
          }]
        },
        payment_note: "Chicago Tool Library annual membership"
      })

    mock_client = Minitest::Mock.new
    mock_client.expect :checkout, mock_checkout

    Square::Client.stub :new, mock_client do
      checkout = SquareCheckout.new(access_token: "SQ_ACCESS_TOKEN", location_id: "SQ_LOCATION_ID")
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

    # No need to assert anything about what params are passed to
    # this method since we do that in the successful case. There doesn't seem to
    # be a way to assert that a mocked method is called with _any_ kwargs.
    mock_checkout = Object.new
    mock_checkout.define_singleton_method :create_payment_link do |args|
      mock_response
    end

    mock_client = Minitest::Mock.new
    mock_client.expect :checkout, mock_checkout

    Square::Client.stub :new, mock_client do
      checkout = SquareCheckout.new(access_token: "SQ_ACCESS_TOKEN", location_id: "SQ_LOCATION_ID")
      result = checkout.checkout_url(
        amount: form.amount,
        email: member.email,
        return_to: "http://example.com/callback",
        member_id: member.id,
        date: Time.zone.local(2024, 1, 1),
        idempotency_key: "test"
      )

      refute result.success?
      assert_equal "ERRORS", result.error
    end

    assert_mock mock_response
    assert_mock mock_client
  end

  test "handles a successful charge" do
    mock_body_order = Minitest::Mock.new
    mock_body_order.expect :[], [{amount_money: {amount: 1200, currency: "USD"}}], [:tenders]

    mock_body = Minitest::Mock.new
    mock_body.expect :order, mock_body_order

    mock_response = Minitest::Mock.new
    mock_response.expect :success?, true
    mock_response.expect :body, mock_body

    mock_orders = Minitest::Mock.new
    mock_orders.expect(:retrieve_order, mock_response, order_id: "order-12345")

    mock_client = Minitest::Mock.new
    mock_client.expect :orders, mock_orders

    Square::Client.stub :new, mock_client do
      checkout = SquareCheckout.new(access_token: "SQ_ACCESS_TOKEN", location_id: "SQ_LOCATION_ID")
      result = checkout.fetch_order(order_id: "order-12345")

      assert result.success?
      assert_equal Money.new(1200), result.value
    end

    assert_mock mock_response
    assert_mock mock_client
    assert_mock mock_orders
    assert_mock mock_body
    assert_mock mock_body_order
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
      checkout = SquareCheckout.new(access_token: "SQ_ACCESS_TOKEN", location_id: "SQ_LOCATION_ID")
      result = checkout.fetch_order(order_id: "order-12345")

      assert result.failure?
      assert_equal "ERRORS", result.error
    end

    assert_mock mock_response
    assert_mock mock_client
    assert_mock mock_orders
  end

  test "generates a checkout URL in the sandbox environment", :remote do
    form = MembershipPaymentForm.new(amount_dollars: 42)

    checkout = SquareCheckout.new(access_token: ENV["SQUARE_ACCESS_TOKEN"], location_id: ENV["SQUARE_LOCATION_ID"], environment: "sandbox")
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
    checkout = SquareCheckout.new(access_token: ENV["SQUARE_ACCESS_TOKEN"], location_id: ENV["SQUARE_LOCATION_ID"], environment: "sandbox")
    result = checkout.fetch_order(order_id: "jnS4zCQGfiqRO1pXSRFZZnyltZ4F")

    assert_nil result.error
    assert result.success?
  end
end
