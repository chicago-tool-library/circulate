FactoryBot.define do
  factory :loan do
    item
    member
    due_at { Time.current+ 1.week }
    uniquely_numbered { true }

    factory :ended_loan do
      created_at { Time.current - 3.weeks }
      due_at { Time.current - 2.weeks }
      ended_at { Time.current - 1.week }
    end
  end
end