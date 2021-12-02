FactoryBot.define do
  factory :category do
    library { Library.first || create(:library) }
    sequence(:name) { |n| "category#{n}" }
  end
end
