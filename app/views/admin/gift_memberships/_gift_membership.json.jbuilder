json.extract! gift_membership, :id, :purchaser_email, :purchaser_name, :amount_cents, :code, :membership_id, :created_at, :updated_at
json.url gift_membership_url(gift_membership, format: :json)
