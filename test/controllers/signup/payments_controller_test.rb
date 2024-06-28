require "test_helper"

module Signup
  class PaymentsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup do
      create(:agreement_document)
      post signup_members_url, params: {
        member_signup_form: attributes_for(:member, password: "password", password_confirmation: "password")
      }
      assert_redirected_to signup_agreement_url
      @member = Member.find(session[:member_id])
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
          return_to: "http://example.com/signup/payments/callback",
          member_id: @member.id,
          date: Date.current)

        SquareCheckout.stub :new, mock_checkout do
          post signup_payments_url, params: {membership_payment_form: {amount_dollars: "12"}}
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

      SquareCheckout.stub :new, mock_checkout do
        post signup_payments_url, params: {membership_payment_form: {amount_dollars: "12"}}
      end

      assert_redirected_to "http://example.com/signup/payments/new"
      follow_redirect!

      assert_select ".toast-error", /There was a problem connecting to our payment processor/

      assert_mock mock_result
      assert_mock mock_checkout
    end

    test "successful callback invocation" do
      get callback_signup_payments_url, params: {orderId: "abcd1234"}

      assert_redirected_to signup_confirmation_url
      assert session[:payment]
    end
  end
end
