require "test_helper"

module Renewal
  class PaymentsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup do
      create(:agreement_document)
      @member = create(:verified_member)
      @membership = create(:membership, member: @member, started_at: 13.months.ago, ended_at: 1.month.ago)
      create(:adjustment,
        kind: Adjustment.kinds[:payment],
        payment_source: Adjustment.payment_sources[:square],
        amount: Money.new(50))
      create(:adjustment,
        adjustable: @membership,
        kind: Adjustment.kinds[:membership],
        amount: Money.new(-50))
      sign_in @member.user
    end

    test "creates a checkout_url" do
      mock_result = Minitest::Mock.new
      mock_result.expect :success?, true
      mock_result.expect :value, "https://squareup.com/checkout/12345"

      mock_checkout = Minitest::Mock.new
      Time.use_zone "America/Chicago" do
        mock_checkout.expect(:checkout_url, mock_result,
          amount: Money.new(1200),
          email: @member.email,
          return_to: "http://example.com/renewal/payments/callback",
          member_id: @member.id,
          date: Date.current)

        SquareCheckout.stub :new, mock_checkout do
          post renewal_payments_url, params: {membership_payment_form: {amount_dollars: "12"}}
        end

        assert_redirected_to "https://squareup.com/checkout/12345"

        assert_mock mock_result
        assert_mock mock_checkout
      end
    end

    test "fails to create a checkout_url" do
      mock_result = Minitest::Mock.new
      mock_result.expect :success?, false
      mock_result.expect :error, [{code: "SOMETHING_WENT_WRONG"}]

      mock_checkout = Minitest::Mock.new
      mock_checkout.expect(:checkout_url, mock_result,
        amount: Money,
        email: String,
        return_to: String,
        member_id: Integer,
        date: Date)

      SquareCheckout.stub :new, mock_checkout do
        post renewal_payments_url, params: {membership_payment_form: {amount_dollars: "12"}}
      end

      assert_redirected_to "http://example.com/renewal/payments/new"
      follow_redirect!

      assert_select ".toast-error", /There was a problem connecting to our payment processor/

      assert_mock mock_result
      assert_mock mock_checkout
    end

    test "successful callback invocation" do
      mock_result = Minitest::Mock.new
      mock_result.expect :success?, true
      mock_result.expect :value, Money.new(1234)

      mock_checkout = Minitest::Mock.new
      mock_checkout.expect(:fetch_transaction, mock_result,
        member: @member,
        transaction_id: "abcd1234")

      SquareCheckout.stub :new, mock_checkout do
        assert_difference "Membership.count" => 1, "Adjustment.count" => 2 do
          get callback_renewal_payments_url, params: {transactionId: "abcd1234"}
        end
      end

      assert_redirected_to renewal_confirmation_url
      assert_equal 1234, session[:amount]
      refute session[:member_id]

      assert_mock mock_result
      assert_mock mock_checkout
    end

    test "failed callback invocation" do
      mock_result = Minitest::Mock.new
      mock_result.expect :success?, false
      mock_result.expect :error, [{code: "ERROR_CODE"}]

      mock_checkout = Minitest::Mock.new
      mock_checkout.expect :fetch_transaction, mock_result, member: Member, transaction_id: String

      SquareCheckout.stub :new, mock_checkout do
        assert_no_difference ["Membership.count", "Adjustment.count"] do
          get callback_renewal_payments_url, params: {transactionId: "abcd1234"}
        end
      end

      assert_redirected_to "http://example.com/renewal/confirmation"

      follow_redirect!
      assert_select ".toast-error", /There was an error processing your payment/

      assert_mock mock_result
      assert_mock mock_checkout
    end

    test "failed callback invocation by not finding a transaction" do
      mock_result = Minitest::Mock.new
      mock_result.expect :success?, false
      mock_result.expect :error, [{code: "NOT_FOUND"}]

      mock_checkout = Minitest::Mock.new
      mock_checkout.expect :fetch_transaction, mock_result, member: Member, transaction_id: String

      SquareCheckout.stub :new, mock_checkout do
        assert_no_difference ["Membership.count", "Adjustment.count"] do
          get callback_renewal_payments_url, params: {transactionId: "abcd1234"}
        end
      end

      assert_equal 200, response.status

      assert_equal 1, session[:attempts]

      assert_mock mock_result
      assert_mock mock_checkout
    end

    test "failed callback invocation by not finding a transaction 10 times" do
      11.times do |i|
        mock_result = Minitest::Mock.new
        mock_result.expect :success?, false
        mock_result.expect :error, [{code: "NOT_FOUND"}]

        mock_checkout = Minitest::Mock.new
        mock_checkout.expect :fetch_transaction, mock_result, member: Member, transaction_id: String

        SquareCheckout.stub :new, mock_checkout do
          get callback_renewal_payments_url, params: {transactionId: "abcd1234"}
        end

        assert_mock mock_result
        assert_mock mock_checkout

        if i < 10
          assert_equal 200, response.status
          assert_equal i + 1, session[:attempts]
        else
          assert_redirected_to "http://example.com/renewal/confirmation"
          assert_match(/There was an error processing your payment/, flash[:error])
          refute session[:attempts]
        end
      end
    end
  end
end
