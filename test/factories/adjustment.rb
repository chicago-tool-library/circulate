FactoryBot.define do
  factory :adjustment do
    amount_cents { -100 }
    amount_currency { "USD" }
    member

    factory :fine_adjustment do
      association :adjustable, factory: :loan
    end

    factory :membership_adjustment do
      association :adjustable, factory: :membership
    end

    factory :cash_payment_adjustment do
      payment_source { "cash" }
    end

    factory :square_payment_adjustment do
      payment_source { "square" }
      square_transaction_id { "transaction_id" }
    end
  end
end