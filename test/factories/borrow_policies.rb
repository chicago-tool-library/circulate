FactoryBot.define do
  factory :borrow_policy do
    library { Library.first || create(:library) }
    sequence(:code, "b")
    name { "Policy ##{code.upcase}" }
    duration { 7 }
    fine_cents { 0 }
    fine_currency { "USD" }
    fine_period { 1 }
    renewal_limit { 2 }
    description { "What this policy is used for" }
    uniquely_numbered { true }
    member_renewable { false }

    factory :member_renewable_borrow_policy do
      code { "A" }
      member_renewable { true }
    end

    factory :unnumbered_borrow_policy do
      uniquely_numbered { false }
      code { "a" }
    end

    factory :consumable_borrow_policy do
      consumable { true }
      uniquely_numbered { false }
    end

    factory :default_borrow_policy do
      name { "Default" }
      duration { 7 }
      fine_cents { 0 }
      fine_period { 7 }
      code { "D" }
    end
  end
end
