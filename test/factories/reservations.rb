FactoryBot.define do
  factory :reservation do
    sequence(:name) { |n| "A reservation ##{n}" }
    started_at { Time.current.at_beginning_of_day }
    ended_at { 1.week.since.at_beginning_of_day }
    submitted_by { association(:user) }
    library { Library.first || association(:library) }
    organization

    trait :pending do
      status { "pending" }
      notes { nil }
    end

    trait :requested do
      status { "requested" }
      notes { nil }
    end

    trait :approved do
      status { "approved" }
      notes { "This reservation has been approved! :)" }
    end

    trait :rejected do
      status { "rejected" }
      notes { "This reservation has been rejected :(" }
    end
  end
end
