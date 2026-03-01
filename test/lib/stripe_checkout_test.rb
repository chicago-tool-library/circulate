require "test_helper"

class StripeCheckoutTest < ActiveSupport::TestCase
  test "#initialize creates a stripe client" do
    api_key = SecureRandom.hex(10)
    stripe_checkout = StripeCheckout.new(api_key)

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
end
