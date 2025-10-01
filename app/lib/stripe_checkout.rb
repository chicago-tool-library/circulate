class StripeCheckout
  def initialize(api_key, now: Time.current)
    @client = Stripe::StripeClient.new(api_key)
    @now = now
  end

  def ensure_customer_exists(user)
    if user.stripe_customer_id.blank?
      customer = @client.v1.customers.create({metadata: {circulate_id: user.id}})
      user.update!(stripe_customer_id: customer.id)
    end
  end

  def sync_payment_methods(user)
    list_payment_methods(user).value.each do |pm|
      next unless pm.card

      payment_method = user.payment_methods.find_or_initialize_by(stripe_id: pm.id)
      payment_method.update!(
        display_brand: pm.card.display_brand,
        last_four: pm.card.last4,
        expire_month: pm.card.exp_month,
        expire_year: pm.card.exp_year
      )
    end
  end

  def delete_payment_method(payment_method)
    response = @client.v1.payment_methods.detach(payment_method.stripe_id)
    payment_method.detach!
    Result.success(response)
  rescue Stripe::InvalidRequestError => e
    Result.failure(e)
  end

  def list_payment_methods(user)
    payment_methods = @client.v1.payment_methods.list({
      customer: user.stripe_customer_id,
      type: "card"
    })
    Result.success(payment_methods)
  rescue Stripe::InvalidRequestError => e
    Result.failure(e)
  end

  def prepare_to_collect_payment_info(user)
    ensure_customer_exists(user)
    setup_intent = @client.v1.setup_intents.create({
      customer: user.stripe_customer_id,
      payment_method_types: ["card"]
    })

    Result.success(setup_intent.client_secret)
  rescue Stripe::InvalidRequestError => e
    Result.failure(e)
  end
end
