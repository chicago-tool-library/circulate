FactoryBot.define do
  factory :stem do
    question { association(:question) }
    sequence(:content) { |n| "Do you plan on borrowing this for #{n} days?" }
    answer_type { "text" }

    trait :integer do
      answer_type { "integer" }
    end

    trait :text do
      answer_type { "text" }
    end
  end
end
