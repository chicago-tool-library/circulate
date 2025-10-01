require "stripe"

Stripe.max_network_retries = 2
Stripe.log_level = Stripe::LEVEL_INFO
