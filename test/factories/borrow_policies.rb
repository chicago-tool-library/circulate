FactoryBot.define do

  factory :borrow_policy do
    sequence(:code, "b")
    name { "Policy ##{code}" }
    duration { 7 }
    fine_cents { 100 }
    fine_currency { "USD" }
    fine_period { 1 }
    description { "What this policy is used for" }
    uniquely_numbered { true }

    factory :unnumbered_borrow_policy do
      uniquely_numbered { false }
      code { "a" }
    end
  end
end
