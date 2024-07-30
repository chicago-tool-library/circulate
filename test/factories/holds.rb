FactoryBot.define do
  factory :hold do
    library { Library.first || association(:library) }
    member
    item
    creator { association(:user) }

    factory :expired_hold do
      started_at { 3.weeks.ago }
      expires_at { 2.weeks.ago }
    end

    factory :ended_hold do
      ended_at { Time.current }
    end

    factory :started_hold do
      after(:build) { |hold| hold.start! }
    end

    trait :ended do
      ended_at { 1.day.ago }
    end

    trait :expired do
      started_at { 3.weeks.ago }
      expires_at { 2.weeks.ago }
    end

    trait :started do
      started_at { 1.hour.ago }
      expires_at { 1.week.from_now }
    end

    trait :waiting do
      started_at { nil }
      expires_at { nil }
    end

    trait :active do
      ended_at { nil }
    end

    factory :previous_active_hold do
      transient do
        for_hold do
          association(:hold, :active, item:)
        end
      end
      active
      item { association(:item, :uniquely_numbered) }
      position { for_hold.position - 1 }
    end
  end
end
