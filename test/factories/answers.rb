FactoryBot.define do
  factory :answer do
    stem { association(:stem, :text) }
    reservation { association(:reservation) }
    result { {"text" => "lorem ipsum"} }

    trait :integer do
      stem { association(:stem, :text) }
      result { {"integer" => [1, 2, 3].sample} }
    end

    trait :text do
      stem { association(:stem, :text) }
      result { {"text" => "lorem ipsum"} }
    end
  end
end
