FactoryBot.define do
  factory :membership do
    member
    started_on { Time.current - 1.month }
    after(:build) { |m| m.ended_on = m.started_on + 364.days if m.started_on }

    factory :pending_membership do
      started_on { nil }
      ended_on { nil }
    end
  end
end
