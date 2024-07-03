FactoryBot.define do
  factory :question do
    library { Library.first || association(:library) }
    sequence(:name) { |n| "Question ##{n}" }
  end
end
