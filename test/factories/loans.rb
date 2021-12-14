FactoryBot.define do
  factory :loan do
    library { Library.first || create(:library) }
    item
    association :member, factory: :verified_member
    due_at { Time.current + 1.week }
    uniquely_numbered { true }

    factory :ended_loan do
      created_at { Time.current - 3.weeks }
      due_at { Time.current - 2.weeks }
      ended_at { Time.current - 1.week }
    end

    factory :overdue_loan do
      created_at { Time.current - 2.weeks }
      due_at { Time.current - 1.week }
    end

    factory :nonexclusive_loan do
      uniquely_numbered { false }
    end
  end
end
