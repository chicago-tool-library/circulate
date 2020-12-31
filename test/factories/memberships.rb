FactoryBot.define do
  factory :membership do
    member
    started_at { Time.current - 1.month }
    after(:build) { |m| m.ended_on = m.started_at + 364.days if m.started_at }

    factory :pending_membership do
      started_at { nil }
      ended_on { nil }
    end
  end
end
