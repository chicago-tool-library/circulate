FactoryBot.define do
  factory :organization do
    sequence(:name) { |n| "Organization #{n}" }
    sequence(:website) { |n| "https://#{n}.example.com" }
    library { Library.first || association(:library) }
  end
end
