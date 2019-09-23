require "test_helper"
require "minitest/mock"

module Signup
  class PaymentsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup do
      post signup_members_url, params: {member: attributes_for(:member)}
      assert_redirected_to signup_agreement_url
      @member = Member.find(session[:member_id])
    end

    test "creates a checkout_url" do
      mock_result = Minitest::Mock.new
      mock_result.expect :success?, true
      mock_result.expect :value, "https://squareup.com/checkout/12345"

      mock_checkout = Minitest::Mock.new
      mock_checkout.expect :checkout_url, mock_result, [{
        amount: Money.new(1200),
        email: @member.email,
        return_to: "http://www.example.com/signup/payments/callback",
        member_id: @member.id,
      }]

      SquareCheckout.stub :new, mock_checkout do
        post signup_payments_url, params: {signup_payment: {amount_dollars: "12"}}
      end

      assert_redirected_to "https://squareup.com/checkout/12345"
    end

    test "fails to create a checkout_url" do
      mock_result = Minitest::Mock.new
      mock_result.expect :success?, false
      mock_result.expect :error, "something went wrong"

      mock_checkout = Minitest::Mock.new
      mock_checkout.expect :checkout_url, mock_result, [Hash]

      SquareCheckout.stub :new, mock_checkout do
        post signup_payments_url, params: {signup_payment: {amount_dollars: "12"}}
      end

      assert_redirected_to "http://www.example.com/signup/payments/new"
      follow_redirect!

      assert_select ".toast-error", "something went wrong"
    end

    test "successful callback invocation" do
      mock_result = Minitest::Mock.new
      mock_result.expect :success?, true
      mock_result.expect :value, Money.new(1234)

      mock_checkout = Minitest::Mock.new
      mock_checkout.expect :fetch_transaction, mock_result, [{
        member: @member,
        transaction_id: "abcd1234",
      }]

      SquareCheckout.stub :new, mock_checkout do
        assert_difference "Membership.count" => 1, "Adjustment.count" => 2 do
          get callback_signup_payments_url, params: {transactionId: "abcd1234" }
        end
      end

      assert_redirected_to signup_confirmation_url
      assert_equal 1234, session[:amount]
      refute session[:member_id]
    end

    test "failed callback invocation" do
      mock_result = Minitest::Mock.new
      mock_result.expect :success?, false
      mock_result.expect :error, "something went wrong"
      mock_result.expect :error, "something went wrong"

      mock_checkout = Minitest::Mock.new
      mock_checkout.expect :fetch_transaction, mock_result, [Hash]

      SquareCheckout.stub :new, mock_checkout do
        assert_no_difference ["Membership.count", "Adjustment.count"] do
          get callback_signup_payments_url, params: {transactionId: "abcd1234" }
        end
      end

      assert_equal @member.id, session[:member_id]
      follow_redirect!

      assert_select ".toast-error", /Your payment could not be processed/
    end
  end
end