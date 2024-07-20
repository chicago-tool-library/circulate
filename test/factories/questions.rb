FactoryBot.define do
  factory :question do
    library { Library.first || association(:library) }
    sequence(:name) { |n| "Question ##{n}" }

    trait :archived do
      archived_at { Time.current }
    end

    trait :unarchived do
      archived_at { nil }
    end
  end
end
