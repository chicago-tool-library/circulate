FactoryBot.define do
  factory :adjustment do
    amount_cents { -100 }
    amount_currency { "USD" }
    member

    factory :fine_adjustment do
      association :adjustable, factory: :loan
      kind { "fine" }
    end

    factory :membership_adjustment do
      association :adjustable, factory: :membership
      kind { "membership" }
    end

    factory :donation_adjustment do
      kind { "donation" }
    end

    factory :cash_payment_adjustment do
      amount_cents { 100 }
      payment_source { "cash" }
      kind { "payment" }
    end

    factory :square_payment_adjustment do
      amount_cents { 100 }
      payment_source { "square" }
      square_transaction_id { "transaction_id" }
      kind { "payment" }
    end
  end
end
