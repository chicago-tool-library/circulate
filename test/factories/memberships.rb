FactoryBot.define do
  factory :membership do
    member
    started_on { Time.current - 1.month }
    ended_on { started_on + 11.months }

    factory :pending_membership do
      started_on { nil }
      ended_on { nil }
    end
  end
end
