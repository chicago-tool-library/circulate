FactoryBot.define do
  factory :borrow_policy_approval do
    borrow_policy { association(:borrow_policy, :requires_approval) }
    member { association(:verified_member) }

    trait :approved do
      status { "approved" }
      status_reason { ["Long time member in good standing", "Cool person", "Pure of heart"].sample }
    end

    trait :rejected do
      status { "rejected" }
      status_reason { ["Too new", "Tends to break things"].sample }
    end

    trait :requested do
      status { "requested" }
    end

    trait :revoked do
      status { "revoked" }
      status_reason { ["Broke too many things", "Never returned the last item"].sample }
    end
  end
end
