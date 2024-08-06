FactoryBot.define do
  factory :loan do
    library { Library.first || create(:library) }
    item
    association :member, factory: :verified_member
    due_at { 1.week.from_now }
    uniquely_numbered { true }

    factory :ended_loan do
      created_at { 3.weeks.ago }
      due_at { 2.weeks.ago }
      ended_at { 1.week.ago }
    end

    factory :overdue_loan do
      created_at { 2.weeks.ago }
      due_at { 1.week.ago }
    end

    factory :nonexclusive_loan do
      uniquely_numbered { false }
    end

    trait :checked_out do
      ended_at { nil }
    end

    trait :exclusive do
      uniquely_numbered { true }
    end
  end
end
