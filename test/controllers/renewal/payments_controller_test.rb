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
        mock_checkout.expect(:slow_sandbox_environment?, false)

        SquareCheckout::Client.stub :new, mock_checkout do
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
      mock_result.expect :error, SquareCheckout::SquareError.new("something went wrong")
      mock_result.expect :error, SquareCheckout::SquareError.new("something went wrong")

      mock_checkout = Minitest::Mock.new
      mock_checkout.expect(:checkout_url, mock_result,
        amount: Money,
        email: String,
        return_to: String,
        member_id: Integer,
        date: Date)

      SquareCheckout::Client.stub :new, mock_checkout do
        post renewal_payments_url, params: {membership_payment_form: {amount_dollars: "12"}}
      end

      assert_redirected_to "http://example.com/renewal/payments/new"
      follow_redirect!

      assert_select ".toast-error", /There was a problem connecting to our payment processor/

      assert_mock mock_result
      assert_mock mock_checkout
    end

    test "successful callback invocation" do
      get callback_renewal_payments_url, params: {orderId: "abcd1234"}

      assert_redirected_to renewal_confirmation_url
      assert session[:payment]
    end
  end
end
