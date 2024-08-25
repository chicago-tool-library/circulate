require "square"

class SquareController < ApplicationController
  # Square doesn't send CSRF tokens
  skip_before_action :verify_authenticity_token

  before_action :validate_request_signature

  def callback
    order_id = params.dig :data, :object, :payment, :order_id

    if order_id
      SquarePaymentJob.perform_later(order_id: order_id)
      head :ok
    else
      head :unprocessable_entity
    end
  end

  private

  # Ensure this request is actually from Square
  def validate_request_signature
    signature = request.env["HTTP_X_SQUARE_HMACSHA256_SIGNATURE"]
    body = request.body.read

    signature_key = ENV["SQUARE_PAYMENT_WEBHOOK_SIGNATURE_KEY"].dup
    notification_url = ENV["SQUARE_PAYMENT_WEBHOOK_NOTIFICATION_URL"].dup
    valid = Square::WebhooksHelper.is_valid_webhook_event_signature(body, signature, signature_key, notification_url)

    unless valid
      render plain: "Invalid request", status: :unauthorized
    end
  end
end
