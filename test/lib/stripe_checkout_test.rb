require "test_helper"

class StripeCheckoutTest < ActiveSupport::TestCase
  test "#initialize creates a stripe client" do
    api_key = SecureRandom.hex(10)
    stripe_checkout = StripeCheckout.new(api_key)

    assert stripe_checkout.client
    assert_equal Stripe::StripeClient, stripe_checkout.client.class
  end

  test ".build creates a stripe client without needing to pass the API key" do
    stripe_checkout = StripeCheckout.build

    assert stripe_checkout.client
    assert_equal Stripe::StripeClient, stripe_checkout.client.class
  end

  test "#ensure_customer_exists creates a stripe customer and saves its id to the given user when the user lacks a stripe id" do
    stripe_checkout = StripeCheckout.new(ENV.fetch("STRIPE_API_KEY"))
    user = create(:user, stripe_customer_id: nil)

    VCR.use_cassette("create_stripe_customer") do
      stripe_checkout.ensure_customer_exists(user)
    end

    user.reload

    assert user.stripe_customer_id
  end

  test "#ensure_customer_exists does nothing when the user already has a stripe id" do
    stripe_checkout = StripeCheckout.new(SecureRandom.hex(10))
    user = create(:user, stripe_customer_id: SecureRandom.hex(10))
    original_stripe_customer_id = user.stripe_customer_id

    stripe_checkout.ensure_customer_exists(user)

    assert_equal original_stripe_customer_id, user.reload.stripe_customer_id
  end

  test "#sync_payment_methods creates payment method records based on stripe's payment methods" do
    stripe_checkout = StripeCheckout.new(ENV.fetch("STRIPE_API_KEY"))
    user = create(:user, stripe_customer_id: nil)

    assert_equal [], user.payment_methods

    VCR.use_cassette("create_stripe_customer") do
      stripe_checkout.ensure_customer_exists(user)
    end

    VCR.use_cassette("list_stripe_payment_methods") do
      stripe_checkout.sync_payment_methods(user)
    end

    user.reload
    assert_equal 1, user.payment_methods.count

    payment_method = user.payment_methods.first!

    assert payment_method.display_brand
    assert payment_method.last_four
    assert payment_method.expire_month
    assert payment_method.expire_year
  end

  test "#sync_payment_methods updates payment method records based on stripe's payment methods" do
    stripe_checkout = StripeCheckout.new(ENV.fetch("STRIPE_API_KEY"))
    user = create(:user, stripe_customer_id: nil)
    payment_method = create(:payment_method, user:, stripe_id: "pm_1T6Ea8PnUSFzhT0d7yCb8feV")
    original_display_brand = payment_method.display_brand
    original_last_four = payment_method.last_four
    original_expire_month = payment_method.expire_month
    original_expire_year = payment_method.expire_year

    assert_equal 1, user.payment_methods.count

    VCR.use_cassette("create_stripe_customer") do
      stripe_checkout.ensure_customer_exists(user)
    end

    VCR.use_cassette("list_stripe_payment_methods") do
      stripe_checkout.sync_payment_methods(user)
    end

    assert_equal 1, user.reload.payment_methods.count

    payment_method.reload
    refute_equal original_display_brand, payment_method.display_brand
    refute_equal original_last_four, payment_method.last_four
    refute_equal original_expire_month, payment_method.expire_month
    refute_equal original_expire_year, payment_method.expire_year
  end

  test "#list_payment_methods returns the payment methods in stripe" do
    stripe_checkout = StripeCheckout.new(ENV.fetch("STRIPE_API_KEY"))
    user = create(:user, stripe_customer_id: nil)

    VCR.use_cassette("create_stripe_customer") do
      stripe_checkout.ensure_customer_exists(user)
    end

    VCR.use_cassette("list_stripe_payment_methods") do
      result = stripe_checkout.list_payment_methods(user)
      assert result.success?
      assert_equal "visa", result.value.first.card.brand
    end
  end

  test "#list_payment_methods returns a failure when something goes wrong" do
    stripe_checkout = StripeCheckout.new(ENV.fetch("STRIPE_API_KEY"))
    user = create(:user, stripe_customer_id: SecureRandom.hex(10))

    VCR.use_cassette("list_stripe_payment_methods_failure") do
      result = stripe_checkout.prepare_to_collect_payment_info(user)
      assert result.failure?
    end
  end

  test "#prepare_to_collect_payment_info returns the created intent's client secret" do
    stripe_checkout = StripeCheckout.new(ENV.fetch("STRIPE_API_KEY"))
    user = create(:user, stripe_customer_id: nil)

    VCR.use_cassette("create_stripe_customer") do
      stripe_checkout.ensure_customer_exists(user)
    end

    VCR.use_cassette("create_intent") do
      result = stripe_checkout.prepare_to_collect_payment_info(user)
      assert result.success?
      assert result.value
    end
  end

  test "#prepare_to_collect_payment_info returns a failure when something goes wrong" do
    stripe_checkout = StripeCheckout.new(ENV.fetch("STRIPE_API_KEY"))
    user = create(:user, stripe_customer_id: SecureRandom.hex(10))

    VCR.use_cassette("create_intent_failure") do
      result = stripe_checkout.prepare_to_collect_payment_info(user)
      assert result.failure?
    end
  end

  test "#delete_payment_method deletes the payment method from stripe" do
    stripe_checkout = StripeCheckout.new(ENV.fetch("STRIPE_API_KEY"))
    user = create(:user, stripe_customer_id: nil)
    payment_method = create(:payment_method, user:, stripe_id: "pm_1T6Ea8PnUSFzhT0d7yCb8feV")

    VCR.use_cassette("create_stripe_customer") do
      stripe_checkout.ensure_customer_exists(user)
    end

    VCR.use_cassette("delete_stripe_payment_method") do
      result = stripe_checkout.delete_payment_method(payment_method)
      assert result.success?
    end
  end

  test "#delete_payment_method returns a failure when something goes wrong" do
    stripe_checkout = StripeCheckout.new(ENV.fetch("STRIPE_API_KEY"))
    user = create(:user, stripe_customer_id: nil)
    payment_method = create(:payment_method, user:, stripe_id: "does not exist")

    VCR.use_cassette("create_stripe_customer") do
      stripe_checkout.ensure_customer_exists(user)
    end

    VCR.use_cassette("delete_stripe_payment_method_failure") do
      result = stripe_checkout.delete_payment_method(payment_method)
      assert result.failure?
    end
  end
end
