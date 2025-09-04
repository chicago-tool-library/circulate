class StripeController < ApplicationController
  skip_before_action :verify_authenticity_token

  def webhook
    payload = request.body.read
    event = nil

    begin
      event = Stripe::Event.construct_from(
        JSON.parse(payload, symbolize_names: true)
      )
    rescue JSON::ParserError => e
      # Invalid payload
      render status: 400
      return
    end

    # Retrieve the event by verifying the signature using the raw body and the endpoint secret
    signing_secret = ENV["STRIPE_WEBHOOK_SIGNING_SECRET"]
    signature = request.env["HTTP_STRIPE_SIGNATURE"]
    begin
      event = Stripe::Webhook.construct_event(
        payload, signature, signing_secret
      )
    rescue Stripe::SignatureVerificationError => e
      Rails.logger.warn "⚠️  Webhook signature verification failed. #{e.message}"
      render status: 400
      return
    end

    # Handle the event
    case event.type
    when "checkout.session.completed"
      session = event.data.object # contains a Stripe::PaymentIntent
      puts session
    else
      puts "Unhandled event type: #{event.type}"
    end
    render json: {message: :success}
  end
end
