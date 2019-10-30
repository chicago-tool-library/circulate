require "test_helper"

module Signup
  class SquareCheckoutTest < ActiveSupport::TestCase
    test "generates a checkout URL" do
      member = create(:member)
      payment = Payment.new

      mock_body_checkout = Minitest::Mock.new
      mock_body_checkout.expect :[], "http://squareup.com/checkout", [:checkout_page_url]

      mock_body = Minitest::Mock.new
      mock_body.expect :checkout, mock_body_checkout

      mock_response = Minitest::Mock.new
      mock_response.expect :success?, true
      mock_response.expect :body, mock_body

      mock_checkout = Minitest::Mock.new
      mock_checkout.expect :create_checkout, mock_response, [
        {
          location_id: "SQ_LOCATION_ID",
          body: {
            idempotency_key: "test",
            redirect_url: "http://example.com/callback",
            pre_populate_buyer_email: member.email,
            order: {
              order: {
                location_id: "SQ_LOCATION_ID",
                reference_id: member.id.to_s,
                line_items: [{
                  name: "Annual Membership",
                  quantity: "1",
                  base_price_money: {
                    amount: payment.amount.cents,
                    currency: "USD",
                  },
                }],
              },
            },
            note: "Circulate signup payment",
          },
        },
      ]

      mock_client = Minitest::Mock.new
      mock_client.expect :checkout, mock_checkout

      Square::Client.stub :new, mock_client do
        checkout = SquareCheckout.new(access_token: "SQ_ACCESS_TOKEN", location_id: "SQ_LOCATION_ID")
        result = checkout.checkout_url(
          amount: payment.amount,
          email: member.email,
          return_to: "http://example.com/callback",
          member_id: member.id,
          idempotency_key: "test"
        )

        assert result.success?
        assert_equal "http://squareup.com/checkout", result.value
      end

      assert_mock mock_response
      assert_mock mock_client
      assert_mock mock_checkout
      assert_mock mock_body
      assert_mock mock_body_checkout
    end

    test "handles not generating a checkout URL" do
      member = create(:member)
      payment = Payment.new

      mock_response = Minitest::Mock.new
      mock_response.expect :success?, false
      mock_response.expect :errors, "ERRORS"

      mock_checkout = Minitest::Mock.new
      mock_checkout.expect :create_checkout, mock_response, [
        {
          location_id: "SQ_LOCATION_ID",
          body: {
            idempotency_key: "test",
            redirect_url: "http://example.com/callback",
            pre_populate_buyer_email: member.email,
            order: {
              order: {
                location_id: "SQ_LOCATION_ID",
                reference_id: member.id.to_s,
                line_items: [{
                  name: "Annual Membership",
                  quantity: "1",
                  base_price_money: {
                    amount: payment.amount.cents,
                    currency: "USD",
                  },
                }],
              },
            },
            note: "Circulate signup payment",
          },
        },
      ]

      mock_client = Minitest::Mock.new
      mock_client.expect :checkout, mock_checkout

      Square::Client.stub :new, mock_client do
        checkout = SquareCheckout.new(access_token: "SQ_ACCESS_TOKEN", location_id: "SQ_LOCATION_ID")
        result = checkout.checkout_url(
          amount: payment.amount,
          email: member.email,
          return_to: "http://example.com/callback",
          member_id: member.id,
          idempotency_key: "test"
        )

        refute result.success?
        assert_equal "ERRORS", result.error
      end

      assert_mock mock_response
      assert_mock mock_client
      assert_mock mock_checkout
    end

    test "handles a successful charge" do
      member = create(:member)
      mock_body_transaction = Minitest::Mock.new
      mock_body_transaction.expect :[], member.id.to_s, [:reference_id]
      mock_body_transaction.expect :[], [{amount_money: {amount: 1200, currency: "USD"}}], [:tenders]

      mock_body = Minitest::Mock.new
      mock_body.expect :transaction, mock_body_transaction

      mock_response = Minitest::Mock.new
      mock_response.expect :success?, true
      mock_response.expect :body, mock_body

      mock_transactions = Minitest::Mock.new
      mock_transactions.expect :retrieve_transaction, mock_response, [{location_id: "SQ_LOCATION_ID", transaction_id: "transaction_1"}]

      mock_client = Minitest::Mock.new
      mock_client.expect :transactions, mock_transactions

      Square::Client.stub :new, mock_client do
        checkout = SquareCheckout.new(access_token: "SQ_ACCESS_TOKEN", location_id: "SQ_LOCATION_ID")
        result = checkout.fetch_transaction(member: member, transaction_id: "transaction_1")

        assert result.success?
        assert_equal Money.new(1200), result.value
      end

      assert_mock mock_response
      assert_mock mock_client
      assert_mock mock_transactions
      assert_mock mock_body
      assert_mock mock_body_transaction
    end

    test "handles not finding a transaction" do # handles 404 and 429
      member = create(:member)

      mock_response = Minitest::Mock.new
      mock_response.expect :success?, false
      mock_response.expect :errors, "ERRORS"

      mock_transactions = Minitest::Mock.new
      mock_transactions.expect :retrieve_transaction, mock_response, [{location_id: "SQ_LOCATION_ID", transaction_id: "transaction_1"}]

      mock_client = Minitest::Mock.new
      mock_client.expect :transactions, mock_transactions

      Square::Client.stub :new, mock_client do
        checkout = SquareCheckout.new(access_token: "SQ_ACCESS_TOKEN", location_id: "SQ_LOCATION_ID")
        result = checkout.fetch_transaction(member: member, transaction_id: "transaction_1")

        assert result.failure?
        assert_equal "ERRORS", result.error
      end

      assert_mock mock_response
      assert_mock mock_client
      assert_mock mock_transactions
    end
  end
end
