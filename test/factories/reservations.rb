FactoryBot.define do
  factory :reservation do
    sequence(:name) { |n| "A reservation ##{n}" }
    started_at { Time.current.at_beginning_of_day }
    ended_at { 1.week.since.at_beginning_of_day }

    trait :approved do
      status { "approved" }
      notes { "Excited to approve #{name}!" }
    end
  end
end
